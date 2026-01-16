# ART: Sprite & Animation Requirements (Artist)
  Circus vampire-like concept — быстрый набор ассетов для теста пайплайна

# 0. Цель документа
1) Список сущностей, которые нужно нарисовать  
2) Состояния/анимации + объём (направления/кадры)  
3) Уточнение: базовая атака игрока — это **отдельные руки**, которые “кланяются/машут” по кругу вокруг игрока во время бега

# 1. Общие правила (MVP)
## 1.1 Направления
Для персонажей используем 3 направления:
- Up
- Down
- Side (Left/Right через mirror)

## 1.2 Количество кадров (быстро и годно)
MVP:
- Run cycle: 4 кадра на направление (быстро и читаемо)
- Idle: 2 кадра
- Windup: 3 кадра
- Strike: 2 кадра
- Recover: 1 кадр
- Death: 4 кадра

## 1.3 Слои (важно)
1. Player:
   - тело (body) отдельно
   - руки (hands) отдельно (см. раздел 2.1)
2. Umbrella:
   - canopy отдельным спрайтом от pole (для alpha fade)

# 2. P0 ассеты (обязательные)
## 2.1 Player (заводная кукла)
### Body (тело)
Анимации (3 направления):
1. `player_body_idle` — 2 кадра (общий) = 2
2. `player_body_run` — 4 кадра × 3 = 12
3. `player_body_hurt` — 1 кадр (общий) = 1
4. `player_body_death` — 4 кадра (общий) = 4

### Hands (руки для базовой атаки)
Идея: во время атаки рука быстро “проносится” вокруг игрока на радиусе `R_hand`.
Чтобы было дёшево:
1. Руки — отдельный спрайт/анимация, который можно крутить/позиционировать кодом.
MVP вариант:
- `player_hand_swing` — 4 кадра (общая, без направлений)
  - кадры: старт → размытие/удар → продолжение → исчезновение
- (optional) `player_hand_trail` — 1 спрайт “шлейф” (можно VFX)

Если хочется красивее:
- 6 кадров swing, но это P1.

Доп. VFX:
- `vfx_hit_spark` — 3 кадра (маленькая искра при попадании) (P1)

## 2.2 EnemyRoamer (ножницы/реквизит)
Анимации (3 направления):
1. `enemy_run` — 4×3 = 12
2. `enemy_windup` — 3×3 = 9
3. `enemy_strike` — 2×3 = 6
4. `enemy_recover` — 1×3 = 3
5. `enemy_hurt` — 1 (общий) = 3
5. `enemy_death` — 4 (общая) = 4
Итого: 34 кадра

## 2.3 AbilityPoppers (две хлопушки)
### Красная (Манежная)
- `popper_red_idle` — 1
- `popper_red_fire` — 2
- `cone_preview_red` — 1 (полупрозрачный конус)

### Зелёная (Закулисная)
- `popper_green_idle` — 1
- `popper_green_fire` — 2
- `cone_preview_green` — 1

Cooldown/серость:
- делаем кодом (tint/desaturate), без дополнительных кадров

## 2.4 AnchorSpotlight (якорь-прожектор)
Состояния (статичные):
1. `anchor_full`
2. `anchor_stage_1`
3. `anchor_stage_2`
4. `anchor_stage_3`
5. `anchor_destroyed`

## 2.5 ExitCurtain (кулисы)
- `exit_locked`
- `exit_open`

## 2.6 Props / Environment
### Crate (разрушаемый)
- `crate_full`
- `crate_broken`

### HeavyBlock
- `heavyblock_01`

### UmbrellaScreen
- `umbrella_pole`
- `umbrella_canopy`

### SandArea
- `sand_patch_01`

## 2.7 Pickup + UI (минимум)
- `pickup_poppers` (две хлопушки вместе)
UI icons:
- `icon_anchor`
- `icon_pickup`
- `icon_exit`
UI frames:
- `ui_frame_hud` (можно один общий)
- `ui_frame_toast`

# 3. Приоритеты
## P0
- Player body idle/run + hurt/death
- Player hand swing (4 кадра)
- Enemy run/windup/strike/recover/death
- Poppers + cone previews
- Anchor 5 стадий
- Exit locked/open
- Crate full/broken, HeavyBlock, Umbrella pole+canopy, Sand patch
- Pickup + UI icons/frames

## P1 (если есть время)
- spark on hit, crate break vfx, pickup confetti
- anchor light pool
- enemy windup icon

# 4. DoD (готовность для художника)
1. Player бегает независимо от атаки, а руки атакуют отдельно (не ломая анимацию тела)
2. Windup у врага визуально читается
3. Конусы хлопушек читаются и различимы по цвету
4. Якорь показывает прогресс урона (5 стадий)
