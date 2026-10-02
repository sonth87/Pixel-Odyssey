# Schema dữ liệu

Mọi nội dung được mô tả bằng **Resource** của Godot (class có `class_name`, lưu thành `.tres`). Bảng dưới là các trường; kiểu theo GDScript. `ĐỀ XUẤT` — trường có thể thêm/bớt khi làm, nhưng phải cập nhật file này.

Nguyên tắc: **schema chung (`shared/schema`) không chứa khái niệm runner**. Thứ gì chỉ runner hiểu (hiệu ứng, chunk, tốc độ) nằm ở `runner/schema` và *trỏ tới* dữ liệu chung.

## 1. Schema dùng chung (shared/schema)

### CharacterData — nhân vật (dùng cho cả game 1 và game 2)
| Trường | Kiểu | Ý nghĩa |
|---|---|---|
| `id` | StringName | `luffy` |
| `name_key` | String | Key ngôn ngữ tên |
| `forms` | Array[CharacterFormData] | Dạng thường (`base`) và các dạng biến hình |
| `skills` | Array[SkillData] | Tối đa 5 |
| `palette_path` | String | Bảng màu con (cho công cụ art) |
| `sfx` | Dictionary[StringName, AudioStream] | `jump`, `land`, `hurt`, `transform`, `voice_*`... |
| `portrait` | Texture2D | Ảnh chân dung (màn chọn) |

### CharacterFormData — một dạng của nhân vật
| Trường | Kiểu | Ý nghĩa |
|---|---|---|
| `id` | StringName | `base`, `gear4` |
| `name_key` | String | |
| `animation_set` | AnimationSet | |
| `size_class` | enum { STANDARD_64, WIDE_128x64, LARGE_96, HUGE_128 } | Khung frame |

### AnimationSet
| Trường | Kiểu | Ý nghĩa |
|---|---|---|
| `sprite_frames` | SpriteFrames | Tên animation = tag chuẩn |
| `frame_size` | Vector2i | 64×64... |
| `pivot` | Vector2i | Điểm giữa đáy |

`CanonicalAnimations` (hằng trong `shared/schema`) liệt kê tên trạng thái chuẩn và nhóm bắt buộc theo ngữ cảnh (`RUNNER_REQUIRED`, `RUNNER_FORM_REQUIRED`, `ACTION_REQUIRED`). Test kiểm tra mỗi `AnimationSet` có đủ nhóm cần thiết.

### SkillData
| Trường | Kiểu | Ý nghĩa |
|---|---|---|
| `id` | StringName | `gomu_pistol` |
| `name_key` | String | |
| `slot` | int (1–5) | Tương ứng tag `skill_<slot>_*` |
| `form_id` | StringName | Dạng thực hiện được skill (`base`, `gear4`) |
| `vfx` | PackedScene | Hiệu ứng kèm |
| `sfx` | AudioStream | |
| `magnitude` | float | Độ mạnh trừu tượng (game 2 diễn giải thành sát thương) |
| `tags` | Array[StringName] | `melee`, `ranged`, `aoe`, `knockback`... |

Thời lượng các pha lấy từ số frame của tag `startup/active/recovery`, không nhập tay — tránh lệch giữa hình và dữ liệu.

## 2. Schema runner (runner/schema)

### RunnerCharacterProfile — nhân vật trong runner
| Trường | Kiểu | Ý nghĩa |
|---|---|---|
| `character` | CharacterData | Trỏ tới dữ liệu chung |
| `passive_effects` | Array[EffectData] | Nội tại, vĩnh viễn trong run |
| `transform_form_id` | StringName | Dạng khi ăn item biến hình |
| `transform_effects` | Array[EffectData] | Hiệu ứng của dạng biến hình |
| `transform_duration` | float | Giây |
| `role_skills` | Dictionary[StringName, StringName] | Vai trò → skill id (`transform_attack` → `gomu_kong_gun`) |
| `unlock` | UnlockRule | Cách mở khoá (M7) |

### EffectData (lớp gốc) và lớp con
Mỗi hiệu ứng nguyên tố là **một lớp con** với tham số riêng có kiểu (không dùng Dictionary tham số tự do — để editor kiểm tra được):

| Lớp | Tham số |
|---|---|
| `ShieldEffect` | `charges: int` |
| `InvincibleEffect` | — |
| `DestroyOnContactEffect` | `filter: ObstacleFilter` |
| `SpeedMultEffect` | `factor: float` |
| `SizeMultEffect` | `factor: float` |
| `JumpMultEffect` | `factor: float` |
| `ExtraJumpsEffect` | `count: int`, `height_scale: float` |
| `PhaseThroughEffect` | `filter: ObstacleFilter` |
| `BridgeGapsEffect` | — |
| `MagnetEffect` | `radius_px: float` |
| `ScoreMultEffect` | `factor: float` |
| `AutoDestroyEffect` | `cooldown: float`, `filter: ObstacleFilter`, `range_px: float` |
| `DurationMultEffect` | `factor: float` |
| `StatMultEffect` | `stat: enum {ITEM_SPAWN, COIN, PERFECT_WINDOW, COMBO_GAIN}`, `factor: float` |
| `StartShieldEffect` | `charges: int` |
| `PreviewHazardsEffect` | `lookahead_px: float` |
| `RushEffect` | — (bảo vệ toàn phần: va chạm, hố, tường) |

`ObstacleFilter`: tập các loại (`ground_low`, `ground_tall`, `enemy_*`, `air`, `projectile`, ...).

`ContentRegistry` kiểm tra mọi tổ hợp hiệu ứng của item/nội tại/dạng biến hình theo **bất biến E1–E4** ([items §5](../01-game-design/04-items-and-powerups.md#5-bất-biến-của-hiệu-ứng)); `SpeedMultEffect`, `JumpMultEffect`, `SizeMultEffect` có `factor ≥ 1.0` (kiểm tra bằng `@export_range`).

### PowerUpData — item
| Trường | Kiểu | Ý nghĩa |
|---|---|---|
| `id` | StringName | `meat`, `sabaody_bubble` (ID nội dung, được phép dùng tên IP trong content) |
| `category` | enum { COIN, COIN_BAG, SHIELD, TRANSFORM, DEVIL_FRUIT, MAGNET, SPEED } | Loại trung lập; chunk dùng loại này |
| `duration_kind` | enum { INSTANT, TIMED, CHARGES } | |
| `duration` | float | Cho TIMED |
| `effects` | Array[EffectData] | Rỗng với TRANSFORM (lấy từ nhân vật) |
| `sprite_frames` | SpriteFrames | |
| `hud_icon` | Texture2D | |
| `pickup_vfx` | PackedScene | |
| `sfx` | AudioStream | |
| `name_key` | String | |
| `score` | int | Điểm khi nhặt |
| `berries` | int | Tiền khi nhặt |

### WeightedEntry
| Trường | Kiểu |
|---|---|
| `resource` | Resource |
| `weight` | float |

Dùng cho pool trái ác quỷ, pool chunk, bộ chướng ngại vật.

### ObstacleData
| Trường | Kiểu | Ý nghĩa |
|---|---|---|
| `id` | StringName | `billions_grunt` |
| `category` | enum ObstacleCategory | `ground_low`, `ground_tall`, `ground_wide`, `enemy_static`, `enemy_moving`, `air`, `falling`, `projectile`, `hazard` |
| `sprite_frames` | SpriteFrames | `idle`, `telegraph`, `active`, `defeated`, `stomped` (theo hành vi) |
| `hitbox` | Rect2i | Tương đối với pivot |
| `behavior` | ObstacleBehaviorData | Hành vi; mặc định `StaticBehavior` |
| `destructible` | bool | Bị phá bởi năng lực phá (không thì đi xuyên) |
| `stompable` | bool | Đạp được |
| `destroy_vfx` | PackedScene | |
| `sfx` | Dictionary[StringName, AudioStream] | `telegraph`, `active`, `defeated`, `stomped` |

Điểm khi phá/đạp lấy từ [scoring](../01-game-design/05-scoring-progression-meta.md), không khai báo theo từng vật — vì: điểm thưởng kỹ năng không được phụ thuộc vào loại vật ngẫu nhiên gặp phải.

### ObstacleBehaviorData (lớp gốc) và lớp con
Một lớp con cho mỗi hành vi ở [obstacles/enemies §4](../01-game-design/08-obstacles-enemies-npc.md#4-các-hành-vi). Tham số có kiểu (không dùng Dictionary tự do):

| Lớp | Tham số |
|---|---|
| `StaticBehavior` | — |
| `ChargerBehavior` | `trigger_distance: int`, `telegraph_time: float`, `move_speed: float` |
| `PatrolBehavior` | `range: int`, `move_speed: float` (pha do RNG lúc dựng) |
| `LeaperBehavior` | `trigger_distance: int`, `telegraph_time: float`, `leap_height: int`, `leap_duration: float` |
| `FlyerBehavior` | `move_speed: float`, `band: enum {LOW, HIGH}`, `amplitude: int`, `period: float` |
| `ShooterBehavior` | `trigger_distance: int`, `telegraph_time: float`, `projectile: ObstacleData`, `projectile_speed: float`, `band: enum {LOW, HIGH}` |
| `DropperBehavior` | `trigger_distance: int`, `warning_time: float`, `fall_speed: float`, `after_landing: enum {REMAIN_LOW, SHATTER}` |
| `SweeperBehavior` | `trigger_distance: int`, `telegraph_time: float`, `move_speed: float` |

Code hành vi (`runner/world/obstacle/behaviors/`) là **một** nơi duy nhất mô phỏng chuyển động — game và validator dùng chung.

### ObstacleSet — bộ chướng ngại vật của một đoạn
| Trường | Kiểu | Ý nghĩa |
|---|---|---|
| `by_category` | Dictionary[ObstacleCategory, Array[ObstacleSetEntry]] | Loại → các obstacle cụ thể |

`ObstacleSetEntry`: `obstacle: ObstacleData`, `weight: float`, `difficulty_min: int`, `difficulty_max: int`, `behavior_override: ObstacleBehaviorData` (tuỳ chọn — cùng kẻ địch, hành vi khác theo bậc khó).

Chunk đặt **loại** → `ObstacleFactory` tra `ObstacleSet` của đoạn (lọc theo độ khó của chunk) → chọn obstacle cụ thể bằng luồng RNG chunk. Nhờ vậy một chunk dùng được cho Alabasta và Water 7.

### NpcData
| Trường | Kiểu | Ý nghĩa |
|---|---|---|
| `id` | StringName | |
| `tier` | enum { AMBIENT, REACTIVE, SET_PIECE } | |
| `layer` | enum { MID, NEAR } | L3 / L4 |
| `sprite_frames` | SpriteFrames | `idle`, `walk`, `react_*` |
| `walk_speed` | float | px/s trong hệ toạ độ của lớp (âm = đi sang trái) |
| `reactions` | Dictionary[StringName, StringName] | Kích hoạt (`player_near`, `perfect`, `destroy_near`, `transform`, `boss_event`) → tag animation; tối đa 2 |
| `group_size` | Vector2i | Số lượng min–max khi xuất hiện theo nhóm |

`DecorationSetData` của đoạn chứa danh sách `NpcData` có trọng số + mật độ; NPC `SET_PIECE` được đặt bằng `EventTrigger` tại % của đoạn.

### ChunkDefinition — chunk (D-031)
| Trường | Kiểu | Ý nghĩa |
|---|---|---|
| `id` | StringName | |
| `difficulty` | int 1–5 | |
| `weight` | int | Trọng số khi chọn ngẫu nhiên trong pool |
| `speed_min`, `speed_max` | float | Khoảng tốc độ gốc (px/s) được dùng; validator kiểm tra min, giữa, max |
| `tags` | Array[StringName] | `intro`, `breather`, ... |
| `layout` | PackedStringArray | Sơ đồ ký tự, mỗi ký tự = cột 8 px, hàng dưới cùng = mặt đất chuẩn y = 148 |

Ký hiệu `layout`: `#` đất · `.` trống · `l` ground_low · `t` ground_tall · `w` ground_wide · `e` enemy_static · `c` enemy_moving. Cột không có `#` là hố; vật đứng trên mặt đất của cột chứa nó. Độ cao đầu/cuối chunk lấy từ cột đầu/cuối (`ChunkLayout.entry_y()` / `exit_y()`); 6 cột (48 px) mỗi đầu là vùng đệm phẳng, không có vật.

Ví dụ (`content/common/greybox/chunks/gap_then_crate.tres`):
```
........................................
........................................
...........................l............
#############....#######################
```

Code đọc sơ đồ: `ChunkLayout` (runner/world/chunk). Ký hiệu cho vật bay, vật rơi, mối nguy, điểm đặt item, hàng xu sẽ thêm cùng các hành vi tương ứng.

### Pool chunk
`SegmentData.chunk_pool: Array[ChunkDefinition]`; trọng số nằm ở `ChunkDefinition.weight`.

### SegmentData
| Trường | Kiểu | Ý nghĩa |
|---|---|---|
| `id` | StringName | `alabasta_rainbase` |
| `name_key` | String | |
| `length_percent` | float | % của đảo |
| `parallax` | ParallaxSetData | |
| `ground_tileset` | TileSet | |
| `obstacle_set` | ObstacleSet | |
| `chunk_pool` | Array[ChunkDefinition] | |
| `item_slot_chance` | float | Xác suất một điểm đặt có item |
| `decoration` | DecorationSetData | Mảnh nền + NPC + mật độ |
| `events` | Array[EventTrigger] | `at_percent` + `EventData` |
| `ambience` | AudioStream | |
| `transition_in` | ParallaxSetData | Mảnh chuyển tiếp vào đoạn (tuỳ chọn) |

### IslandData
| Trường | Kiểu | Ý nghĩa |
|---|---|---|
| `id` | StringName | |
| `name_key` | String | |
| `kind` | enum { LAND, SEA } | |
| `length_m` | float | |
| `segments` | Array[SegmentData] | Tổng `length_percent` = 100 (ContentRegistry kiểm tra) |
| `speed_start`, `speed_end` | float | Tốc độ gốc đầu/cuối đảo (≤ 300); `speed_start` bằng `speed_end` của đảo trước (ContentRegistry kiểm tra) |
| `difficulty_min`, `difficulty_max` | float | Đường cong độ khó |
| `music_base`, `music_intensity` | AudioStream | |
| `max_devil_fruits`, `max_transform_items` | int | Giới hạn |
| `entry_chunk`, `exit_chunk` | PackedScene | Cập bờ / ra tàu |
| `map_icon` | Texture2D | |
| `ship` | ShipData | Với `SEA`: tàu nào |

### JourneyData
| Trường | Kiểu |
|---|---|
| `islands` | Array[IslandData] (gồm cả đoạn biển, theo thứ tự) |

### ParallaxSetData / ParallaxLayerData
| Trường | Kiểu | Ý nghĩa |
|---|---|---|
| `sky_bands` | PackedColorArray | Dải màu trời |
| `layers` | Array[ParallaxLayerData] | |
| — `layer` | enum { SKY, FAR, MID_FAR, MID, NEAR, FOREGROUND } | |
| — `scroll_scale` | float | |
| — `kind` | enum { PANORAMA, PROPS } | |
| — `texture` | Texture2D | Với PANORAMA |
| — `props` | Array[WeightedEntry] | Với PROPS |
| — `y_anchor` | int | |
| — `density` | float | Với PROPS |

### EventData
| Lớp | Trường |
|---|---|
| `BackgroundEventData` | `scene: PackedScene`, `layer`, `duration` |
| `HazardPatternData` | `chunk: PackedScene` (chunk kịch bản, cũng qua validator), `warmup_breather: bool` |

### ContentPack
| Trường | Kiểu |
|---|---|
| `id` | StringName |
| `name_key` | String |
| `characters` | Array[RunnerCharacterProfile] |
| `default_character` | StringName |
| `journey` | JourneyData |
| `power_ups` | Array[PowerUpData] |
| `devil_fruit_pool` | Array[WeightedEntry] |
| `localization_files` | PackedStringArray |
| `menu_music`, `jingles` | AudioStream / Dictionary |

## 3. Dữ liệu lưu (save)

File JSON `user://save.json` (không dùng Resource cho save — tránh nạp script tuỳ ý từ file người dùng sửa được).

```json
{
  "version": 1,
  "settings": { "music": 0.8, "sfx": 1.0, "language": "vi", "vibration": true,
                "screen_shake": true, "reduce_flashing": false, "content_pack": "onepiece" },
  "packs": {
    "onepiece": {
      "best_distance_m": 0, "best_score": 0, "farthest_island": "",
      "runs": 0, "total_distance_m": 0,
      "selected_character": "luffy",
      "berries": 0, "upgrades": {}, "unlocked": ["luffy"]
    }
  }
}
```
- Mỗi lần đổi cấu trúc: tăng `version`, thêm hàm nâng cấp `v1 → v2` trong `save_migrations.gd`, có test.
- Ghi file an toàn: ghi ra file tạm rồi đổi tên (không mất dữ liệu nếu app bị tắt giữa chừng).
