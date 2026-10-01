# CLAUDE.md

Pixel Odyssey — pixel-art one-button endless runner (Godot 4, GDScript). First content pack: One Piece. A second game (action, Ninja-School-like) will later reuse `game/shared/`.

## Source of truth
- `docs/` is the source of truth. Start at `docs/README.md`. Decisions: `docs/00-overview/04-decision-log.md`. Milestones: `docs/00-overview/03-milestones.md`. Task list and progress (pick work here, tick it off when done): `docs/00-overview/06-roadmap-and-checklists.md`.
- `docs/1. conversation.md` is the raw brainstorm — background only, not authoritative.
- Status tags in docs: `CHỐT` (owner-confirmed), `ĐỀ XUẤT` (proposed, may change with a reason), `MỞ` (open — never assume an answer).
- Physics/gameplay numbers live only in `docs/05-technical/05-physics-collision-generation.md`.
- Game rules on contact (death sources, shield, stomp, interaction matrix, tick order) live in `docs/01-game-design/09-interaction-rules.md`; entity behaviors in `08-obstacles-enemies-npc.md`. Effects must satisfy invariants E1–E4 (`04-items-and-powerups.md` §5).

## Working with the owner
- Communicate in Vietnamese. Code, identifiers, commit messages in English. Docs in Vietnamese; image/audio prompts in English.
- The owner is not a professional game developer: proactively point out game-design or technical consequences they may not see, briefly, with a recommendation.
- Do not discuss copyright/licensing unless the owner raises it (D-011).
- If a request contradicts the docs, say so; when the owner confirms a change, update the relevant doc and add a decision-log entry before coding.
- Stay within the current milestone's scope unless asked.

## Architecture rules
- Layers: `game/shared/` (reusable with game 2) ← `game/runner/` (game-1 gameplay) ← `game/app/`; `game/content/<pack>/` is data + assets only, no gameplay scripts.
- `shared/` must not reference `runner/`, `app/`, or `content/`. `runner/` must not reference `app/` or a specific pack path. Only `ContentRegistry` knows the active pack.
- No IP names (luffy, zoro, gomu, marine, ...) in `shared/` or `runner/` code; use neutral concepts (`transform_item`, `ground_enemy`, `power_up`).
- Data-driven: new characters/islands/items/obstacles = Resources + assets, not code branches. Behavior differences come from data or effect subclasses, never `if id == ...`.
- Determinism: gameplay simulation uses integer fixed-point (1/256 px, no `float`/`Vector2`/`delta`; beware GDScript int `/` truncates toward zero — use `fdiv`), see `docs/05-technical/08-input-rendering-determinism.md`. Gameplay only in `_physics_process` at 60 ticks; all randomness via `RunContext` RNG streams (`chunks`, `items`, `fruits`, `cosmetic`); never global `randi()/randf()` in `runner/`.
- Autoloads are fixed: `EventBus`, `Settings`, `Save`, `Audio`, `ContentRegistry`. Adding one requires a decision-log entry.
- Animation tag names follow `docs/02-art/02-character-animation-spec.md` exactly; skills use `skill_N_startup/active/recovery`.

## Code rules
- Static typing everywhere. One responsibility per file/function. Files ≤ 300 lines, functions ≤ 50 lines, ≤ 4 params. No god files/functions, no dead code, no commented-out code, no speculative features.
- Comments: only non-obvious "why", describing the code as it is now. Never write change history or references to requests/people/tasks ("changed from X", "per user request", "reverted to", "added for M2").
- Validate at boundaries (content loading, save files); use `assert` for internal invariants; no handling for impossible cases.
- Tests (gdUnit4) required for: jump physics, RNG determinism, chunk validator, effect stacking, scoring, save migrations, localization keys, required animation sets.
- After changing physics constants or chunks: run the chunk validator.
- No user-facing strings in code: use localization keys (`docs/04-localization/01-localization.md`).
- Full rules: `docs/05-technical/03-coding-standards.md`.

## Art rules (summary)
- Native pixel art: character frame 64×64, character ~22–24 px tall, chibi, no black outline, flat 2–3 shades, pivot at bottom-center. Viewport 320×180, integer scaling, Nearest filtering. UI on a 640×360 grid.
- AI images are "fake pixel art" — always process with `tools/pixelize.py`, then clean up in Pixelorama; export one PNG strip per animation tag and run `tools/check_sprites.py`. See `docs/02-art/05-ai-image-pipeline.md`.

## Workflows
Use the project skills in `.claude/skills/` when the task matches: `add-character`, `add-island`, `add-content`, `sprite-pipeline`, `add-audio`, `record-decision`.
