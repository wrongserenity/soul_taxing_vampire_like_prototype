# AUDIO: SFX & Music Requirements (Sound Designer)
  Circus vampire-like concept — фокус на читаемости, телеграфах и “шоу-моментах”

# 0. Цель документа
1) Список всех SFX/музыки для MVP  
2) Анти-каша: concurrency, приоритеты, сайдчейн/ducking  
3) Привязка звука к AttackBase events (windup/active/recover/cooldown)

# 1. Принципы звука
1. Читаемость > реализм
2. AttackBase-driven звук:
   - windup_start = телеграф/aim
   - active_start = удар/выстрел/попадание
3. Различимость ролей:
   - Red (бой): резкий хлопок + панч + whoosh (knockback)
   - Green (прогресс): хлопок + “техно/дерево/электрика” (anchor/crate)

# 2. AudioMix System (анти-каша + сайдчейн) — обязательная часть MVP
## 2.1 Buses
- Music
- SFX_Player
- SFX_Enemy
- SFX_Ability
- SFX_UI

## 2.2 Concurrency / Voice limiting
Минимально:
- popper_red_fire: max 2 одновременно
- popper_green_fire: max 2 одновременно
- enemy_strike_hit: max 3
- ui_click: max 1
Cooldown:
- мелкие “ticks” не чаще чем раз в 0.1–0.2с

## 2.3 Priorities
High:
- enemy_windup_telegraph
- objective_exit_unlocked_stinger
- win/lose stinger
Mid:
- popper_aim / popper_fire
- player_hurt
- anchor_stage_off
Low:
- footsteps
- sand loop
- мелкие hit ticks

## 2.4 Sidechain / Ducking (MVP минимум 2 триггера)
1. enemy_windup_telegraph:
   - duck Music на 0.2–0.4 sec
2. objective_exit_unlocked_stinger:
   - duck всё кроме stinger на 0.5–1.0 sec

Параметры ducking должны быть настраиваемыми.

# 3. SFX список (P0 must-have)
## 3.1 Player
1. `player_hurt` (2 варианта)
2. `player_death` (1)
3. `player_levelup` (1 цирковой “та-да!”)
4. BowHandsAttack (через AttackBase):
   - `player_hand_windup` (optional, если windup > 0)
   - `player_hand_swing` (active_start) (2 варианта “свист/вжух”)
   - `player_hand_hit` (on hit, optional 2 варианта)

## 3.2 Enemy
1. `enemy_spawn` (1)
2. `enemy_windup_telegraph` (2 варианта, High)
3. `enemy_strike_hit` (2 варианта)
4. `enemy_strike_miss` (1)
5. `enemy_death` (2 варианта)

## 3.3 AbilityPoppers — Red (Манежная)
1. `popper_red_aim` (2 варианта, Mid/High)
2. `popper_red_fire` (2–3 варианта)
3. `popper_red_hit_enemy` (2 варианта)
4. `popper_red_knockback_whoosh` (1–2 варианта)

## 3.4 AbilityPoppers — Green (Закулисная)
1. `popper_green_aim` (2 варианта)
2. `popper_green_fire` (2–3 варианта)
3. `popper_green_hit_anchor` (2 варианта)
4. `popper_green_hit_crate` (2 варианта)
5. `crate_break` (2 варианта) (можно считать как часть green feedback)

## 3.5 AnchorSpotlight
1. `anchor_hit` (1)
2. `anchor_stage_off` (3 варианта или 1 с random pitch)
3. `anchor_destroyed` (1)
4. (optional) `anchor_hum_loop` (1 loop, тихий)

## 3.6 Exit/Objectives/UI
1. `objective_anchor_destroyed_stinger` (1)
2. `objective_exit_unlocked_stinger` (1, High)
3. `win_stinger` (1)
4. `lose_stinger` (1)
5. UI:
   - `ui_click` (2 варианта)
   - `ui_pause_open` (1)
   - `ui_pause_close` (1)
   - `ui_toast_show` (1)

## 3.7 Environment
1. `heavyblock_bump` (1)
2. (optional) `footsteps` (2–3 варианта)
3. (optional) `sand_loop` (1 loop)

# 4. Music (минимум)
1. `music_main_loop` (2–4 минуты loop, цирк/театр)
2. (optional) `music_dramatic_loop` (2–4 минуты loop, цирк/театр)

# 5. DoD (готовность для саунд-дизайнера)
1. P0 звуки интегрированы по событиям AttackBase (windup/active)
2. Enemy windup слышен даже в толпе (priority + ducking)
3. Red/Green отличаются тембром и не смешиваются в кашу (concurrency + mix)
4. Есть минимум 2 ducking триггера (enemy_windup + exit_unlocked)
