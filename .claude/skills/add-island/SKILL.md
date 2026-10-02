---
name: add-island
description: Workflow to add a new island, sea passage, segment, or chunk to the runner's journey (spec, parallax art, chunks, validation, events, audio). Use when the owner asks to add/plan an island or location, a sea section, a segment, or new obstacle chunks.
---

# Add an island / sea passage / segment / chunk

Communicate with the owner in Vietnamese. The Alabasta spec is the template.

## 0. Read first
- `docs/01-game-design/02-run-journey-and-stages.md` — structure, chunk rules, transitions, boss events.
- `docs/01-game-design/07-island-alabasta.md` — template.
- `docs/02-art/03-environment-parallax-spec.md` — layers, rules, prompts.
- `docs/05-technical/05-physics-collision-generation.md` — obstacle limits, validator.
- `docs/05-technical/04-data-schemas.md` — `IslandData`, `SegmentData`, `ChunkDefinition`, `ObstacleSet`, `ParallaxSetData`, `EventData`.

## A. New island
1. **Spec**: copy `07-island-alabasta.md` → `docs/01-game-design/islands/<id>.md` (or next numbered file). Fill: length, difficulty range, speed clamp, item limits, music, palette mood, segments (each: feel, layers L1–L6, NPCs, obstacles by category, chunk tags/difficulty, item chance, events, ambience), exit chunk, following sea passage, asset list. Add/update the island row in the journey table (`02-run-journey-and-stages.md`). Get owner approval on the spec.
2. **Palettes**: `art-source/palettes/segments/<segment_id>.gpl` (≤ 24 colors).
3. **Parallax art** per segment (use `sprite-pipeline`): sky bands, L1/L2 tileable panoramas (check seams in Pixelorama tile mode), L3/L4/L6 prop pieces, transition pieces between segments, ground tileset (flat ×3 variants, pit edges, steps 8/16/24, transition tile).
4. **Obstacles/enemies/NPCs**: use the `add-content` skill; build one `ObstacleSet` per segment (category → weighted obstacles).
5. **Chunks**: see section C. Target 15–25 chunks per segment (reuse `content/common/chunks/` where possible).
6. **Events**: `BackgroundEventData` scenes (visual only, ≤ 40% darkening, respect reduce-flashing) and `HazardPatternData` chunks (must pass the validator; placed between breathers).
7. **Data**: `game/content/<pack>/islands/<id>/` → `SegmentData` ×N (percent sum = 100), `IslandData`, entry/exit chunks; insert into `JourneyData` at the correct order.
8. **Audio**: island music (base + intensity stems), ambience per segment (`add-audio`).
9. **Text**: `<pack>.island.<id>.name`, `<pack>.segment.<id>.name` (vi, en).

## B. New sea passage
`IslandData` with `kind = SEA`: ship deck tileset, sea parallax, sea chunk pool (deck obstacles, cannon fire with warnings, waves), arrival piece showing the next island, music `music_sea` or variant. Exit chunk of the previous island must place the ship within a tap-jump (+20% margin) at that island's max speed.

## C. New chunk
Chunks are text layouts (D-031, schema: `docs/05-technical/04-data-schemas.md` § ChunkDefinition).
1. Create a `ChunkDefinition` `.tres` in the right folder (`content/common/...` if pack-neutral, else the segment's `chunks/`); set `id`, `difficulty`, `weight`, `speed_min/max`, `tags`.
2. Write `layout`: one character per 8 px column, bottom row = standard ground. `#` ground, `.` empty, `l/t/w` ground_low/tall/wide, `e` enemy_static, `c` enemy_moving. Keep 6 flat, obstacle-free columns at both ends; entry/exit ground must match neighbours (same height in the pool).
3. Place obstacles by **category letter**; the segment's `ObstacleSet` picks the concrete obstacle. Respect the size limits table.
4. Run the validator: `godot --headless --path game -s res://runner/validation/validate_all.gd` (exit 1 on error). Fix until green.
5. Add the chunk to the segment's `chunk_pool`.
6. Playtest in the greybox scene (`app/dev/greybox_run.tscn`, chunk id in the overlay, F4 slow motion).

## Verify
- [ ] Validator green for all chunks of the island.
- [ ] Full island playable from entry to ship without visual seams or pop-in.
- [ ] Obstacles readable on every layer combination; NPCs not confusable with enemies.
- [ ] 60 FPS on the reference Android device.
- [ ] Docs updated (spec, journey table) and real production time noted.
