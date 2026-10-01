---
name: sprite-pipeline
description: Turn AI-generated "pixel art" images into real game-ready pixel sprites (prompt assembly, pixelize.py processing, Aseprite cleanup and tagging, export, Godot import, verification). Use when the owner asks for an image prompt, gives an AI-generated image to process, or wants a sprite sheet checked or imported.
---

# Sprite pipeline

Communicate with the owner in Vietnamese; prompts are in English. Full reference: `docs/02-art/05-ai-image-pipeline.md`, `docs/02-art/06-prompt-library.md`, `docs/02-art/01-art-style-guide.md`.

## 1. Prompt (when the owner asks "viết prompt cho ...")
1. Find the item in the right spec (`02-character-animation-spec.md`, `03-environment-parallax-spec.md`, `04-obstacles-items-vfx-ui-spec.md`). If missing, add a row + description there first.
2. Assemble blocks in order: `STYLE` (S-CHAR/S-PROP/S-ENV/S-VFX/S-UI) + `SUBJECT` (C-<ID> or content) + `POSE`/content + `OUTPUT` (O-SINGLE/O-STRIP(n)/O-EDIT/O-PROP/O-LAYER) + `AVOID`.
3. Output the full ready-to-paste prompt and list exactly which reference images to attach (style sheet, identity image, previous approved frame upscaled 16× nearest).
4. For any frame after the first approved `idle`, prefer `O-EDIT` from the approved frame.

## 2. Store raw
Save the untouched image to `art-source/raw/<group>/<id>/<tag>/<YYYYMMDD>_<n>.png` with a sibling `.prompt.md` (model, date, references, full prompt, notes).

## 3. Process
```
python tools/pixelize.py <raw.png> --frame 64x64 --palette art-source/palettes/characters/<id>.gpl [--strip N]
```
- Use `--frame none` for backgrounds/props, the matching frame for wide/large forms.
- Read the report: detected grid, colors before/after, warnings. If grid detection is uncertain, retry with `--grid <n>`, or tell the owner the image needs manual reduction in Aseprite (Sprite → Sprite Size, nearest).
- Show the owner the processed result (upscaled preview) before cleanup when the pose itself is in doubt.

## 4. Aseprite (owner does manual cleanup; Claude can guide)
- One `.aseprite` per character/form/enemy in `art-source/aseprite/<group>/`.
- Canvas = frame size; tags named exactly per the animation spec; frame durations from the spec FPS; palette = the sub-palette.
- Fix feet to the bottom row, center the body, remove stray pixels, draw in-betweens with onion skin.

## 5. Export and import
```
tools/export_aseprite.sh <file.aseprite>      # sheet + json into game/content/<pack>/.../sprites/
```
- Characters: no trim (keep frame size for a stable pivot).
- Godot: Nearest filter (project default), lossless, no mipmaps; SpriteFrames animation names = tags; pivot offset so (frame_w/2, frame_h) is the node origin.

## 6. Verify (report each item to the owner)
- [ ] Frame size correct; feet on the bottom row in every grounded frame; body centered.
- [ ] Alpha only 0/255; no black outline; colors within the sub-palette (count them).
- [ ] Character height consistent (~22–24 px) except intentional squash/stretch.
- [ ] Required tags present for the current milestone (B1/B2).
- [ ] Silhouette readable at 1×; loops play without jitter.
- [ ] `.prompt.md` exists next to every raw image used.

A quick automated check can be done with Python/Pillow on the exported PNG: frame grid divisibility, alpha values, unique color count, bottom-row occupancy per frame.
