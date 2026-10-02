# Kiến trúc

## 1. Mục tiêu kiến trúc

| Mục tiêu | Từ yêu cầu | Cách đạt |
|---|---|---|
| Đổi chủ đề không sửa code | W7, NFR-EX-02 | Content pack chỉ là dữ liệu + asset; code đọc qua `ContentRegistry` |
| Thêm nhân vật/đảo/item không sửa code | NFR-EX-01 | Thiết kế hướng dữ liệu (Resource), hiệu ứng nguyên tố ghép được |
| Dùng lại cho game 2 | W8 | Lớp `shared` độc lập, không biết gì về runner |
| Tất định theo seed | NFR-DT-01 | Gameplay chạy ở tick vật lý cố định; mọi ngẫu nhiên qua luồng RNG của run |
| Dễ bảo trì | W10 | Hệ thống nhỏ, một việc; giao tiếp qua signal; quy tắc ở [coding standards](03-coding-standards.md) |

## 2. Các lớp và chiều phụ thuộc

```
┌──────────────────────────────────────────────────────────────┐
│ app/          khởi động, điều hướng màn hình, menu, kết quả  │
└───────────────┬───────────────────────────┬──────────────────┘
                ▼                           ▼
┌──────────────────────────────┐   ┌───────────────────────────┐
│ runner/   gameplay game 1    │   │ content/<pack>/            │
│ (vật lý nhảy, chunk, item,   │◄──┤ CHỈ dữ liệu (.tres, .tscn  │
│  điểm, parallax, sự kiện)    │   │ chunk) + asset, không code │
└───────────────┬──────────────┘   └─────────────┬─────────────┘
                ▼                                ▼
┌──────────────────────────────────────────────────────────────┐
│ shared/   dùng chung với game 2                               │
│ core: EventBus, StateMachine, RngStreams, SaveService,        │
│       SettingsService, AudioService, ObjectPool, Localization │
│ schema: CharacterData, AnimationSet, SkillData, ...           │
└──────────────────────────────────────────────────────────────┘
```

**Luật phụ thuộc** (NFR-MT-02, kiểm tra tự động bằng `tools/check_layers.py`):
- `shared/` không được tham chiếu `runner/`, `app/`, `content/`.
- `runner/` không được tham chiếu `app/` hay một content pack cụ thể bằng đường dẫn.
- `content/` không chứa script gameplay. Được phép dùng class Resource của `shared/schema` và `runner/schema` để khai báo dữ liệu.
- Chỉ `ContentRegistry` biết pack nào đang được chọn.

Vì sao: nếu `shared` lỡ phụ thuộc `runner`, đến lúc tách cho game 2 sẽ phải gỡ rối cả mạng phụ thuộc.

## 3. Autoload (toàn cục)

Danh sách **cố định**; thêm autoload mới phải ghi decision log. Vì: autoload là biến toàn cục — dễ dùng, dễ lạm dụng, khó test.

| Autoload | Lớp | Trách nhiệm |
|---|---|---|
| `EventBus` | shared | Signal cho sự kiện liên hệ thống (danh sách mục 6) |
| `Settings` | shared | Đọc/ghi cài đặt người dùng, phát `setting_changed` |
| `Save` | shared | Lưu/đọc dữ liệu tiến trình, có phiên bản và nâng cấp |
| `Audio` | shared | Phát nhạc/SFX theo bus, crossfade, ducking, giới hạn đồng thời |
| `ContentRegistry` | app | Nạp content pack đang chọn, cung cấp dữ liệu cho runner |

**Không** có autoload "GameManager" chứa mọi thứ. Trạng thái của một run nằm trong `RunContext` do `RunController` tạo, sống và chết cùng run.

## 4. Các hệ thống của runner

```
RunController ──tạo──► RunContext { seed, rng streams, distance, speed, journey cursor }
     │
     ├── SpeedController        tốc độ theo quãng đường, kẹp theo đảo, nhân hiệu ứng
     ├── Player (scene)
     │     ├── RunnerBody        tích phân chuyển động riêng, tick cố định
     │     ├── JumpController    chạm/giữ, coyote, buffer, nhảy thêm
     │     ├── PlayerStateMachine  Running / Airborne / Transforming / Dead
     │     ├── EffectHost        danh sách hiệu ứng đang có → tổng hợp Modifiers
     │     ├── Hurtbox
     │     └── CharacterView     AnimatedSprite2D, chọn animation theo trạng thái (chỉ hình)
     ├── CollisionResolver      va chạm hurtbox↔hitbox → hỏi EffectHost → chết/phá/bỏ qua/mất khiên
     ├── World
     │     ├── StageDirector     quãng đường → đảo/đoạn hiện tại; phát segment_entered
     │     ├── ChunkSpawner      chọn chunk (luồng RNG chunk), dựng chunk từ pool đối tượng
     │     ├── ObstacleFactory   loại → obstacle cụ thể theo ObstacleSet của đoạn
     │     ├── ItemSpawner       điểm đặt item → item (luồng RNG item, giới hạn)
     │     ├── DecorationSpawner NPC/mảnh nền (luồng RNG trang trí)
     │     ├── ParallaxController lớp nền theo đoạn, chuyển tiếp
     │     └── EventDirector     sự kiện nền / mẫu đặc biệt
     ├── Scoring
     │     ├── ScoreKeeper       quãng đường, điểm, combo, hệ số
     │     └── PerfectDetector   phát hiện perfect jump
     └── Presentation
           ├── CameraRig         theo dọc, rung (tôn trọng cài đặt)
           ├── FeedbackService   hit-stop, rung máy, flash (tôn trọng giảm nhấp nháy)
           └── Hud
```

### 4.1 Trạng thái người chơi

| Trạng thái | Vào khi | Ra khi |
|---|---|---|
| `Running` | Chạm đất | Nhảy / rời mép (sau coyote) / chết / biến hình |
| `Airborne` | Nhảy hoặc rời mép | Chạm đất / chết |
| `Transforming` | Bắt đầu hoặc kết thúc biến hình (bất tử, giữ vật lý chạy) | Hết animation biến hình |
| `Dead` | CollisionResolver kết luận chết, hoặc rơi khỏi màn hình | Run kết thúc |

State machine là lớp chung `shared/core/state_machine` (mỗi trạng thái một file nhỏ). Biến hình **không** là bộ trạng thái riêng: dạng biến hình chỉ đổi `AnimationSet` của `CharacterView` và thêm hiệu ứng vào `EffectHost`.

### 4.2 Hệ thống hiệu ứng (EffectHost)

- Mỗi item/nội tại là danh sách `EffectData` (Resource có kiểu riêng cho từng hiệu ứng).
- `EffectHost` giữ các hiệu ứng đang hoạt động với thời hạn (giây/lần/vĩnh viễn), áp quy tắc chồng ([items](../01-game-design/04-items-and-powerups.md#6-quy-tắc-chồng-hiệu-ứng-fr-it-05)).
- `CollisionResolver` làm đúng thứ tự xử lý và ma trận ở [luật tương tác](../01-game-design/09-interaction-rules.md); mỗi ô của ma trận có test.
- Mỗi tick tính lại `Modifiers` (giá trị đã gộp + kẹp: `speed_mult`, `jump_mult`, cờ `invincible`, bộ lọc phá, số khiên...).
- Các hệ thống khác **chỉ đọc `Modifiers`**, không hỏi "đang có item gì". Vì: thêm item mới không phải sửa SpeedController hay CollisionResolver.

### 4.3 Va chạm

Không dùng bộ giải vật lý của Godot cho người chơi (không `CharacterBody2D.move_and_slide` với lực/ma sát). `RunnerBody` tự tính vị trí theo công thức ở [physics](05-physics-collision-generation.md), va chạm mặt đất và va chạm nguy hiểm (hurtbox/hitbox) đều bằng phép so hình chữ nhật số nguyên trong mô phỏng, không dùng `Area2D` — vì `Area2D` chạy bằng số thực và theo nhịp của bộ vật lý Godot, phá tính tất định (D-027). Vì: kiểm soát hoàn toàn cảm giác nhảy, tất định, validator dùng **cùng một hàm tích phân** với game.

## 5. Tính tất định

- Gameplay chạy trong `_physics_process` ở **60 tick/giây cố định**. Không dùng `delta` của khung hình trong logic gameplay.
- Vị trí/vận tốc trong mô phỏng là **số nguyên cố định** (D-027) → kết quả giống nhau trên mọi CPU; node hiển thị chỉ đọc giá trị này.
- Input được lượng tử hoá theo tick (nhấn/thả ghi nhận ở tick nào).
- `RngStreams` tạo từ seed của run các luồng độc lập: `chunks`, `items`, `fruits`, `cosmetic`. Cấm dùng `randi()`/`randf()` toàn cục trong `runner/`.
- Trang trí dùng luồng `cosmetic` → số lượng NPC thay đổi không làm lệch chuỗi chunk.
- Animation, particle, camera chỉ là hình — không ảnh hưởng gameplay.
- Lợi ích: thử thách hằng ngày, tái hiện lỗi (ghi seed + chuỗi input → phát lại).

## 6. Sự kiện (EventBus)

Chỉ cho sự kiện mà **nhiều hệ thống không liên quan** cần biết. Giao tiếp cha-con dùng signal trực tiếp hoặc gọi hàm.

| Signal | Tham số | Ai nghe |
|---|---|---|
| `run_started` | seed, character_id | Hud, Audio, Analytics |
| `run_ended` | RunResult | App (mở kết quả), Save |
| `player_jumped` | is_high | Audio, Feedback |
| `player_landed` | — | Audio, VFX |
| `player_died` | cause | Audio, Feedback, RunController |
| `obstacle_passed` | obstacle_id, perfect | ScoreKeeper, Feedback |
| `obstacle_destroyed` | obstacle_id | ScoreKeeper, VFX |
| `item_collected` | item_id | ScoreKeeper, Audio, Hud |
| `effect_started` / `effect_ended` | effect id | Hud, Audio |
| `segment_entered` | island_id, segment_id | Parallax, Audio, Decoration, EventDirector |
| `island_entered` | island_id | Audio, ScoreKeeper, Hud |
| `setting_changed` | key, value | Audio, Feedback, Localization |

Quy ước tên: thì quá khứ (`player_died`), không phải mệnh lệnh.

## 7. Nạp nội dung

1. `Settings` cho biết pack đang chọn (mặc định `onepiece`).
2. `ContentRegistry` nạp `content/<pack>/pack.tres` (`ContentPack`) → nhân vật, hành trình, item, pool trái ác quỷ, file ngôn ngữ, âm thanh chung của pack.
3. `ContentRegistry` kiểm tra hợp lệ (nhân vật đủ animation bắt buộc, đảo có tổng % = 100, chunk pool không rỗng...) và báo lỗi rõ ràng nếu thiếu — đây là ranh giới hệ thống nên kiểm tra kỹ.
4. `RunController` nhận dữ liệu từ `ContentRegistry`, không tự load đường dẫn.

## 8. Hiệu năng

- **Object pool** cho chướng ngại vật, item, VFX, NPC, mảnh nền (NFR-PF-02). Chunk khi ra khỏi màn hình trả đối tượng về pool.
- Chỉ giữ chunk trong khoảng [-1 màn hình, +2 màn hình] quanh nhân vật.
- Parallax dùng `Parallax2D` (Godot ≥ 4.3) với `repeat_size` cho toàn cảnh lặp.
- Texture gộp atlas theo đoạn khi tới M8 nếu đo thấy cần.
- Đo trên máy thật từ M3.
