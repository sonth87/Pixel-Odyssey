---
name: add-content
description: Workflow to add an obstacle, enemy, power-up item, devil fruit, background NPC, or VFX to a content pack of the pixel runner. Use when the owner asks to add or design any of these.
---

# Add an obstacle / enemy / item / NPC / VFX

Communicate with the owner in Vietnamese. Everything here is data + assets; code changes only if a new primitive effect or obstacle behavior is truly needed (then stop and propose it separately).

## 0. Read first
- `docs/01-game-design/01-core-gameplay.md` §4 (obstacle categories) and `04-items-and-powerups.md` (items, effects, stacking, spawn limits).
- `docs/02-art/04-obstacles-items-vfx-ui-spec.md` (sizes, readability rules, prompts).
- `docs/05-technical/05-physics-collision-generation.md` §4–5 (hitbox rules, size limits).
- `docs/05-technical/04-data-schemas.md` (`ObstacleData`, `ObstacleSet`, `PowerUpData`, effect classes, `WeightedEntry`).

## Obstacle or enemy
1. Pick the **category** (`ground_low`, `ground_tall`, `ground_wide`, `enemy_static`, `enemy_moving`, `air`, `falling`, `hazard`, `gap`, `terrain_step`). The category defines how it is overcome — the art must read as that category (silhouette rule).
2. Add a row (id, category, sprite size, frames, description) and a prompt to the obstacles spec.
3. Produce art with `sprite-pipeline`: `idle`/`move` + `defeated` (or assign the shared destroy VFX). Enemies face LEFT.
4. Create `ObstacleData` in `game/content/<pack>/islands/<island>/obstacles/`: hitbox = sprite inset 2 px sides/top, within category limits; `destructible`, `move_speed`, `warning_time` (falling/air ≥ 0.6 s), `score_on_destroy`, sfx.
5. Add it to the relevant `ObstacleSet`(s) with a weight.
6. If hitbox exceeds what existing chunks assumed → run the validator on all chunks using that category.

## Power-up item
1. Pick `category` and `duration_kind`; compose `effects` from existing effect classes. Check stacking rules still make sense (§5 of the items doc) and that totals stay within clamps.
2. Add rows to the items doc (table + HUD icon description) and a prompt to the art spec.
3. Art: world sprite (2–4 frames), HUD icon 12×12 (world) / 24×24 (UI), pickup VFX if unique.
4. Create `PowerUpData` in `game/content/<pack>/items/`; register in `pack.tres`.
5. Spawn rules: which `ItemSlot` risk level, per-island limits if valuable.
6. Text keys (`<pack>.item.<id>.name`), sfx via `add-audio`.

## Devil fruit (random pool entry)
Same as power-up with `category = DEVIL_FRUIT`, plus: add a `WeightedEntry` to `devil_fruit_pool`, a unique HUD icon, name key `<pack>.fruit.<id>.name`, and re-run the 10,000-run distribution simulation test.

## Background NPC
1. Layer L3 (12–16 px, 2 frames) or L4 (18–22 px, 2–4 frames); paler/lower contrast than gameplay; must not resemble the segment's enemies.
2. Add to the segment's decoration set with density/weight.

## VFX
1. Add a row + prompt to the VFX table (size, frames, trigger).
2. Sprite-based (not soft particles); alpha 0/255 only.
3. Hook it through data (obstacle `destroy_vfx`, item `pickup_vfx`, skill `vfx`) — not code.

## Verify
- [ ] Readable at 1× on every background it appears on.
- [ ] Data passes `ContentRegistry` validation; tests pass.
- [ ] Validator green if any hitbox/category assumptions changed.
- [ ] Docs updated (tables, prompts).
