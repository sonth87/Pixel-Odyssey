---
name: add-audio
description: Workflow to add music, sound effects, or ambience to the pixel runner (prompt or sfxr parameters, processing, file formats, bus routing, data hookup). Use when the owner asks for a sound/music prompt or wants audio added or checked.
---

# Add audio

Communicate with the owner in Vietnamese; prompts in English. Reference: `docs/03-audio/01-audio-spec.md`.

## 1. Define
- Add/confirm a row in the right table (music / SFX / ambience) with ID, trigger, description.
- Music: island theme in chiptune with the region's flavor; plan `base` + `intensity` stems for islands.
- SFX: short, chiptune; give sfxr preset/parameter hints and an AI prompt.

## 2. Produce
- Music prompt for Suno/Udio (instrumental, chip sound, scale/mood, BPM, seamless loop, length).
- SFX: jsfxr/ChipTone (save the parameter .json) or ElevenLabs prompt.
- Store originals in `art-source/audio-raw/<type>/<id>/` with `.prompt.md` or the sfxr `.json`.

## 3. Process (Audacity)
- Trim silence; 5 ms fades on SFX; cut music loops at zero crossings; normalize: music ≈ -16 LUFS, SFX peak ≤ -3 dBFS.
- Export: music/ambience OGG Vorbis 44.1 kHz stereo; SFX WAV 44.1 kHz 16-bit mono.

## 4. Place and hook up
- Pack-specific: `game/content/<pack>/audio/{music,sfx,ambience}/`; shared UI sounds: `game/shared/audio/ui/`.
- Godot import: loop on for music/ambience (set loop offset if there is an intro).
- Reference the stream from data (`IslandData.music_*`, `SegmentData.ambience`, `CharacterData.sfx`, `PowerUpData.sfx`, `ObstacleData.sfx`) — not from code.
- Bus: Music / SFX / UI / Ambience as defined in the spec; set a max-polyphony for frequent sounds (coins).

## 5. Verify
- [ ] Plays on the right bus; volume settings affect it.
- [ ] Loops seamlessly (listen to 3 loops).
- [ ] Not louder/quieter than neighbors; no clipping when stacked.
- [ ] Every important audio cue also has a visual cue (accessibility).
