# DEV: Systems & Entities Requirements (Programmer)
  Circus vampire-like concept — прототип для теста пайплайна + костяк LamKit

# 0. Цель документа
1) Сущности (Scenes/Nodes) и их ответственность  
2) Системы MVP (LamKit) с упором на переиспользование  
3) События (events/signals) для VFX/SFX/UI  
4) Минимальные конфиги (какие параметры обязаны быть вынесены в данные)

# 1. Сущности (Scenes / Nodes)
## 1.1 Player (CharacterBody2D)
Ответственность:
1. Input + Movement (WASD 8-way, gamepad 360)
2. `HealthComponent` (HP=100) + death/restart
3. XP/Leveling (`leveling_lib/mc`)
4. Базовая атака: **BowHandsAttack**
   - не “пульс”, а махи руками, как поклон
   - персонаж бежит как обычно, но “рука” быстро проходит по кругу на расстоянии `R_hand` от центра игрока (нужно решить руки будут двигаться по кругу по спрайтовой анимации или просто картинка руки будет крутиться)
   - руки — отдельные визуальные элементы (см. ART док)
5. Collision policy:
   - Player НЕ блокируется Enemy (ghost-through)
   - Player блокируется Props (Crate/HeavyBlock/UmbrellaPole)
6. Events (must-have):
   - `player_hurt`, `player_death`, `player_levelup`
   - `attack_windup_start`, `attack_strike_start`, `attack_recover_start`, `attack_end` (см. AttackBase)

## 1.2 EnemyRoamer (CharacterBody2D + NavigationAgent2D)
Ответственность:
1. Spawn offscreen
2. Chase via Navigation2D/NavMesh
3. `HealthComponent` + death + XP drop
4. MeleeAttack через AttackBase:
   - Chase → Windup → Strike → Recover → Chase
   - фиксация направления от windup до recover
5. Events:
   - `enemy_windup`, `enemy_strike`, `enemy_death`

## 1.3 AbilityPoppers (две пассивные хлопушки)
Состав:
1. `AbilityPoppers` (Node2D child of Player)
2. `RedPopper` ("Манежная") — targets: enemies only
3. `GreenPopper` ("Закулисная") — targets: anchors > crates

Поведение (обязательно):
- orbit вокруг игрока `R_orbit`, ideally opposite
- targeting scan `N_scan`, radius `R_target`, line-of-sight (HeavyBlock blocks)
- атака хлопушки тоже через AttackBase:
  - Aim/Windup → Strike/Fire (apply damage) → Recover → Cooldown
- red: dmg enemies `1.5*N3` + knockback `K_push`
- green: dmg anchors/crates `2.0*N3`, ignores enemies

## 1.4 AnchorSpotlight (objective)
1. `HealthComponent` + `DamageReceiver`
2. HP: `100 + 200 * destroyed_anchors`
3. Stage thresholds: 100/95/60/25/0 (визуальные стадии)
4. Events:
   - `anchor_stage_changed`, `anchor_destroyed`

## 1.5 ExitCurtain
1. Locked until 3 anchors destroyed
2. Unlock event + win trigger
3. Events:
   - `exit_unlocked`, `win_triggered`

## 1.6 Props / Environment
1. `Crate` (разрушаемый)
   - `HealthComponent` (HP_crate)
   - blocks movement + cuts navmesh (как статик)
2. `HeavyBlock` (неразрушаемый)
   - blocks movement
   - cuts navmesh
   - blocks LOS
3. `UmbrellaScreen`
   - pole collider + canopy overlay + alpha fade near player
   - optional heal aura (можно резать)
4. `SandArea`
   - Status zone: apply Slow via StatusController/ModifierHub

## 1.7 UI Scenes
1. HUD: HP + XP/Level
2. Pause: resume, volume, restart, quit
3. Toast notifications
4. Offscreen markers (anchor / pickup / exit)

# 2. Системы LamKit (MVP) — упор на системность
## 2.1 HealthComponent (универсальное “здоровье”)
Цель: один компонент работает на Player/Enemy/Crate/Anchor.
1. Параметры:
   - `max_hp`, `hp`
2. API:
   - `apply_damage(DamageEvent)`
   - `heal(amount)`
   - `is_dead()`
3. Events:
   - `on_damaged(amount, source, type)`
   - `on_death(source, type)`
   - `on_hp_changed(current, max)`

## 2.2 Damage System (типы урона + фильтрация)
Цель: исключить “friendly fire” и легко настраивать кто что дамажит.
1. `DamageEvent` содержит:
   - `amount`
   - `damage_type` (enum/string)
   - `source_faction` (Player/Enemy/Neutral)
   - `source_id` (опционально)
2. `DamageReceiver` / `DamageFilter` на каждой сущности:
   - `allowed_damage_types` (список)
   - `allowed_source_factions` (список)
Пример:
- Enemy принимает только damage_type = PlayerMelee/RedPopper
- Anchor принимает PlayerMelee/GreenPopper
- Crate принимает PlayerMelee/GreenPopper
- Player принимает EnemyMelee (и может игнорить свои типы)

## 2.3 AttackBase (унифицированный таймлайн атаки)
Цель: одна реализация для Enemy melee, Player hand-bow, Popper shot.
Фазы:
1. `Windup` (подготовка/телеграф/прицеливание)
2. `Active` (окно нанесения урона / попадания)
3. `Recover` (короткая пауза)
4. `Cooldown` (до следующей атаки)

Требования:
- Тайминги задаются данными
- Events:
  - `on_windup_start`
  - `on_active_start` (момент применения урона/нокбэка)
  - `on_recover_start`
  - `on_cooldown_start`
  - `on_attack_end`
- Поддержка “фиксировать направление” (для enemy) и “двигаться во время атаки” (для player)

## 2.4 BowHandsAttack (Player базовая атака)
Реализация через AttackBase:
- Windup: короткий (optional)
- Active: рука(и) быстро проходят дугу/кольцо вокруг игрока на радиусе `R_hand`
- Recover: короткий
- Cooldown: общий интервал между махами `N2`
Hit logic:
- либо hitbox ring, который двигается по дуге
- либо несколько коротких сегментов-хитбоксов по кругу (простая реализация)
DamageEvent:
- `damage_type = PlayerMelee`
- `source_faction = Player`

## 2.5 PopperAttack (Red/Green)
Тоже AttackBase:
- Windup/Aim: `N_pop_aim` (preview cone + prefire SFX)
- Active/Fire: apply damage cone
- Recover: короткий
- Cooldown: до следующего выстрела (`N_pop_rate`)

Damage types:
- Red: `damage_type = RedPopper`
- Green: `damage_type = GreenPopper`
Faction: Player

## 2.6 Spawner / Objectives / Markers / UI
1. Spawner curve: зависит от destroyed_anchors (0/1/2/3)
2. Objective: 3 anchors destroyed -> unlock exit
3. Markers: anchor/pickup/exit
4. UI: HP/XP, pause, toasts

## 2.7 ModifierHub (единая калитка модификаторов)
MVP:
- stat: `move_speed`
- source list: `source_id -> mul/add`
- cap: итог ≥ 50% базы
Используется на Player+Enemy.

## 2.8 StatusController (статус-эффекты)
MVP:
- Slow_Sand (enter/exit area) -> ModifierHub.set_mod(move_speed, "sand", mul=0.75)
Optional:
- InvulnAfterHit (player)

## 2.9 AudioMix System (анти-каша + сайдчейн)
1. Buses: Music, SFX_Player, SFX_Enemy, SFX_Ability, SFX_UI
2. Concurrency limits (one-shots)
3. Priorities (enemy windup и objective stingers выше всего)
4. Sidechain ducking:
   - enemy_windup → duck music/low sfx
   - exit_unlocked → duck everything

# 3. Минимальные параметры, которые обязаны быть в данных
## 3.1 Player config
- `base_move_speed (N1)`
- `max_hp`
- `xp_curve_ref`
- BowHandsAttack:
  - `attack_interval (N2)`
  - `hand_damage (N3)`
  - `hand_radius (R_hand)`
  - `windup_time`
  - `active_time`
  - `recover_time`
  - `damage_type` (=PlayerMelee)

## 3.2 Enemy config
- `base_move_speed (N4)`
- `max_hp (N5)`
- `xp_reward (N11)`
- MeleeAttack:
  - `melee_radius (R_melee)`
  - `windup_time (N6_windup)`
  - `active_time (N_hit_time)`
  - `recover_time (N_recover)`
  - `damage_amount (N7)`
  - `damage_type` (=EnemyMelee)
- `nav_agent_settings` (минимум max_speed)

## 3.3 Popper config (общий + по цветам)
Общее:
- `orbit_radius (R_orbit)`
- `scan_interval (N_scan)`
- `target_radius (R_target)`
- `cone_range (R_cone)`
- `cone_angle (A_cone)`
- Attack:
  - `aim_time (N_pop_aim)`
  - `active_time`
  - `recover_time`
  - `cooldown_time (N_pop_rate)`
Red:
- `damage_multiplier (1.5)`
- `knockback_force (K_push)`
- `damage_type` (=RedPopper)
Green:
- `damage_multiplier (2.0)`
- `damage_type` (=GreenPopper)

## 3.4 Anchor config
- `base_hp`
- `hp_per_destroyed_anchor`
- `stage_thresholds` (95/60/25/0)
- `damage_types_allowed` (PlayerMelee, GreenPopper)

## 3.5 Crate config
- `max_hp (HP_crate)`
- `damage_types_allowed` (PlayerMelee, GreenPopper)

## 3.6 HeavyBlock config
- (обычно без параметров) + flags: blocks_los, blocks_nav

## 3.7 SandArea / Status config
- `slow_multiplier` (0.75)
- `min_speed_ratio_cap` (0.5)

## 3.8 Spawner curve config
- spawn_rate для destroyed_anchors = 0/1/2/3
- max_enemies_on_screen (optional)

## 3.9 AudioMix config
- concurrency limits per event
- ducking settings per trigger (depth/attack/release)

# 4. DoD (готовность для программиста)
1. Полный цикл: старт → 3 якоря → выход → win / death → restart
2. Web билд на itch “в один клик”
3. Enemy: chase + windup/strike/recover через AttackBase
4. Player: BowHandsAttack работает во время движения (рука по кругу)
5. Health/Damage/Filter единые на player/enemy/crate/anchor
6. Popper атаки через AttackBase + aim phase events
7. ModifierHub + StatusController + cap 50% базы
8. AudioMix: concurrency + хотя бы один sidechain trigger
