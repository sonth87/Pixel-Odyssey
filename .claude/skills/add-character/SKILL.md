---
name: add-character
description: End-to-end workflow to add a new playable character (design, art, data, audio, localization, verification) to a content pack of the pixel runner. Use when the owner asks to add/create a character, or to plan or check what a character still needs.
---

# Add a character

Goal: the character works in the runner **without changing code** in `game/shared/` or `game/runner/` (NFR-EX-01). Communicate with the owner in Vietnamese.

## 0. Read first
- `docs/01-game-design/03-characters-and-skills.md` — passive, transform, skill roles.
- `docs/02-art/02-character-animation-spec.md` — required tags (B1/B2/G2), frame sizes.
- `docs/05-technical/04-data-schemas.md` — `CharacterData`, `CharacterFormData`, `AnimationSet`, `SkillData`, `RunnerCharacterProfile`, effect classes.
- Current milestone in `docs/00-overview/03-milestones.md`.

## 1. Design (write into docs before producing assets)
1. Add a row to the character table in `03-characters-and-skills.md`: passive, the primitive effects it is built from, transform form + effects + duration, unlock rule.
2. If the passive needs an effect type that does not exist → stop: that is a code change. Tell the owner, propose the new effect type, and handle it as a separate reviewed change (update the effect table in `04-items-and-powerups.md` and `04-data-schemas.md`).
3. List the 5 skills (name, slot) and which skill gets a runner role (`transform_attack`, `passive_visual`).
4. Add a character identity block `C-<ID>` to `docs/02-art/06-prompt-library.md` with fixed outfit colors (hex).

## 2. Palette
- Create `art-source/palettes/characters/<id>.gpl` (≤ 16 colors) derived from `art-source/palettes/master.gpl` and the reference image if one exists (`tools/extract_palette.py`).

## 3. Art (use the `sprite-pipeline` skill for each tag)
Order — each step uses the previous approved frame as reference (O-EDIT):
1. `idle` frame 1 → approve with owner before continuing (identity lock).
2. Remaining B1 tags: `idle`, `run`, `jump_start`, `jump_rise`, `jump_apex`, `fall`, `land`, `hurt`, `death_hit`, `death_lie`, plus `double_jump` if the passive needs it, `eat` if the transform item is eaten.
3. Transform form (`<id>_<form>.pxo`, strips in `sprites/<form>/`): `transform_enter`, `transform_exit`, `form_idle`, `form_run`, `form_jump_rise`, `form_fall`, `form_land`, `form_attack`.
4. Skill tags for skills with a runner role: `skill_N_startup/active/recovery`.
5. B2 tags (`sit`, `sit_idle`, `cheer`, `taunt`, `pickup`, `death_fall`) when the milestone needs menus/results.
Follow the pose principles (animation spec §3) and run the checklist (§6) for every tag.

## 4. Data (in `game/content/<pack>/characters/<id>/`)
1. `<id>.tres` — `CharacterData` (forms, skills, sfx, portrait, name key).
2. Form resources with `AnimationSet` (SpriteFrames from the exported sheet; pivot bottom-center).
3. `SkillData` for each of the 5 skills (`magnitude`, `tags` set; phase durations come from the animation).
4. `<id>_runner.tres` — `RunnerCharacterProfile` (passive effects, transform form id/effects/duration, role skills, unlock).
5. Register the profile in `pack.tres` → `characters`.

## 5. Audio and text
- SFX: `jump`, `land`, `hurt`, `transform` (+ optional voice) via the `add-audio` skill.
- Localization keys in `game/content/<pack>/localization/<pack>.csv`: `<pack>.character.<id>.name`, `.passive_desc`, `.form.<form>.name`, skill names — both `vi` and `en`.

## 6. Verify
- [ ] Tests pass, including "animation set has all required tags".
- [ ] `tools/check_ip_names.py` and `tools/check_layers.py` pass.
- [ ] `git diff --stat` shows no changes under `game/shared/` or `game/runner/` (unless a new effect type was explicitly approved).
- [ ] Play with debug: run, jump (tap/hold), die, transform via debug item spawn, passive visibly works.
- [ ] Character readable on every segment background of the current islands.
- [ ] Record real hours spent in the milestone notes.
