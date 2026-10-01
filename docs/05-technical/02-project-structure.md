# Cấu trúc thư mục

## 1. Repo

```
g1/
├── CLAUDE.md                     quy tắc cho AI agent (đọc mỗi phiên)
├── README.md
├── .gitignore  .gitattributes    (LFS cho ảnh, âm thanh, .aseprite)
├── .claude/skills/               skill quy trình (add-character, add-island, ...)
├── docs/                         tài liệu (nguồn sự thật)
├── assets/                       ảnh tham khảo phong cách (charactors/, 1–3.jpg) — không vào bản build
├── tools/                        script ngoài engine (Python, shell)
│   ├── pixelize.py
│   ├── export_aseprite.sh
│   ├── extract_palette.py
│   ├── check_layers.py           kiểm tra luật phụ thuộc giữa các lớp
│   └── check_ip_names.py         kiểm tra không có tên IP trong shared/ và runner/
├── art-source/                   nguồn art (không vào bản build)
│   ├── palettes/                 master.gpl, characters/<id>.gpl, segments/<id>.gpl
│   ├── raw/                      ảnh AI gốc + .prompt.md
│   ├── processed/                đầu ra pixelize.py
│   ├── aseprite/                 file .aseprite (nguồn chính của sprite)
│   └── audio-raw/                âm gốc + prompt/tham số sfxr
└── game/                         project Godot (project.godot ở đây)
```

Vì sao project Godot nằm trong `game/` thay vì gốc repo: Godot import mọi ảnh trong thư mục project; để `docs/` và `art-source/` (hàng trăm ảnh raw) ngoài project giúp editor nhanh và bản build sạch.

## 2. Project Godot

```
game/
├── project.godot
├── addons/                       plugin bên thứ ba (Aseprite Wizard, gdUnit4)
├── shared/                       ── dùng chung với game 2 ──
│   ├── core/
│   │   ├── event_bus.gd
│   │   ├── state_machine/        state_machine.gd, state.gd
│   │   ├── rng/                  rng_streams.gd
│   │   ├── save/                 save_service.gd, save_migrations.gd
│   │   ├── settings/             settings_service.gd, settings_data.gd
│   │   ├── audio/                audio_service.gd
│   │   ├── pool/                 object_pool.gd
│   │   └── localization/         number_format.gd
│   ├── schema/                   class Resource dùng chung
│   │   ├── character_data.gd
│   │   ├── character_form_data.gd
│   │   ├── animation_set.gd
│   │   ├── canonical_animations.gd   danh sách tên trạng thái chuẩn
│   │   └── skill_data.gd
│   ├── ui/                       theme, font, thành phần UI chung (nút, panel)
│   ├── audio/ui/                 âm UI chung
│   └── localization/ui.csv
├── runner/                       ── gameplay game 1 ──
│   ├── run/                      run_controller.gd, run_context.gd, run_result.gd, speed_controller.gd
│   ├── player/
│   │   ├── player.tscn
│   │   ├── runner_body.gd
│   │   ├── jump_controller.gd
│   │   ├── hurtbox.gd
│   │   ├── character_view.gd
│   │   └── states/               running_state.gd, airborne_state.gd, transforming_state.gd, dead_state.gd
│   ├── effects/
│   │   ├── effect_host.gd
│   │   ├── modifiers.gd
│   │   └── types/                shield_effect.gd, speed_mult_effect.gd, ... (một file / hiệu ứng)
│   ├── collision/                collision_resolver.gd, hitbox.gd
│   ├── world/
│   │   ├── stage_director.gd
│   │   ├── chunk_spawner.gd
│   │   ├── chunk/                chunk_definition.gd, obstacle_slot.gd, item_slot.gd, coin_line.gd
│   │   ├── obstacle/             obstacle.gd, obstacle.tscn, obstacle_factory.gd
│   │   │   └── behaviors/        static_behavior.gd, charger_behavior.gd, ... (một file / hành vi; game và validator dùng chung)
│   │   ├── npc/                  npc.gd, npc_spawner.gd
│   │   ├── item/                 pickup.gd, pickup.tscn, item_spawner.gd
│   │   ├── decoration/           decoration_spawner.gd
│   │   ├── parallax/             parallax_controller.gd
│   │   └── events/               event_director.gd, background_event.gd
│   ├── scoring/                  score_keeper.gd, perfect_detector.gd
│   ├── presentation/             camera_rig.gd, feedback_service.gd, hud/
│   ├── physics/                  jump_physics.gd (công thức dùng chung cho game và validator)
│   ├── validation/               chunk_validator.gd
│   ├── debug/                    debug_overlay.gd, debug_commands.gd
│   └── schema/                   Resource riêng của runner
│       ├── runner_character_profile.gd
│       ├── effect_data.gd (+ các lớp con ở effects/types)
│       ├── power_up_data.gd
│       ├── weighted_entry.gd
│       ├── obstacle_data.gd, obstacle_set.gd
│       ├── chunk_pool.gd
│       ├── segment_data.gd, island_data.gd, journey_data.gd
│       ├── parallax_set_data.gd, parallax_layer_data.gd
│       ├── event_data.gd
│       └── content_pack.gd
├── app/                          ── vỏ ứng dụng ──
│   ├── boot/                     boot.tscn
│   ├── content_registry.gd
│   ├── screens/                  main_menu/, character_select/, run_screen/, results/, settings/, pause/
│   └── router.gd                 chuyển màn hình
├── content/
│   ├── common/                   chunk trung lập dùng chung nhiều đảo/pack
│   │   └── chunks/
│   ├── onepiece/
│   │   ├── pack.tres
│   │   ├── characters/luffy/     luffy.tres, luffy_runner.tres, sprites/, sfx/
│   │   ├── islands/alabasta/     alabasta.tres, segments/, chunks/, obstacles/, parallax/, npcs/, events/
│   │   ├── sea/going_merry/
│   │   ├── items/
│   │   ├── fruits/
│   │   ├── audio/                music/, sfx/, ambience/
│   │   └── localization/onepiece.csv
│   └── original/                 pack thử nghiệm (M5)
└── tests/                        gdUnit4: unit/, integration/
```

## 3. Quy ước đặt tên

| Thứ | Quy ước | Ví dụ |
|---|---|---|
| File script, scene, resource | `snake_case` | `jump_controller.gd`, `luffy_runner.tres` |
| `class_name` | `PascalCase` | `JumpController` |
| Hàm, biến | `snake_case` | `apply_effect()` |
| Hằng số | `UPPER_SNAKE` | `MAX_HOLD_TIME` |
| Signal | thì quá khứ | `player_landed` |
| Node trong scene | `PascalCase` | `Hurtbox`, `CharacterView` |
| ID nội dung | `snake_case`, duy nhất trong pack | `luffy`, `alabasta`, `billions_grunt` |
| Tag animation | theo [bảng chuẩn](../02-art/02-character-animation-spec.md) | `jump_rise` |
| Asset | `<id>_<biến thể>.png` | `rock_tall_2.png` |

Tên trong `shared/` và `runner/` **trung lập với IP** (D-006): `transform_item`, `GroundEnemy`, không phải `meat`, `Marine`.

## 4. Ranh giới khi thêm file

| Bạn đang thêm... | Đặt ở |
|---|---|
| Tiện ích mà game hành động cũng cần (save, audio, state machine) | `shared/core/` |
| Dữ liệu mô tả nhân vật/skill mà game 2 cũng dùng | `shared/schema/` |
| Logic chỉ có ý nghĩa trong runner (nhảy, chunk, combo) | `runner/` |
| Màn hình, điều hướng | `app/` |
| Hình, âm, dữ liệu của một chủ đề | `content/<pack>/` |
| Chunk dùng được cho nhiều đảo | `content/common/chunks/` |
