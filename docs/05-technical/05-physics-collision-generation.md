# Vật lý, va chạm, công bằng, sinh chunk

**Đây là nguồn duy nhất của các thông số gameplay.** Nơi khác chỉ link tới đây. Mọi giá trị là `ĐỀ XUẤT` cho tới khi chỉnh xong ở M1; khi đổi, chạy lại validator toàn bộ chunk và ghi decision log.

Code: thông số nằm trong một Resource `RunnerPhysicsConfig` (`runner/physics/`), được dùng **chung** bởi game và validator. Mô phỏng chạy bằng **số nguyên cố định** (D-027); các giá trị px/s dưới đây là giá trị thiết kế, được quy đổi sang đơn vị nguyên khi nạp.

## 1. Hệ quy chiếu

| Thông số | Giá trị | Ghi chú |
|---|---|---|
| Độ phân giải logic | 320×180, chiều rộng mở rộng tới 400 | D-014 |
| Tick gameplay | 60 / giây | Cố định |
| Đơn vị | 1 px logic; 16 px = 1 m | |
| Trục y | Hướng xuống (theo Godot) | Bảng dưới ghi "độ cao" là khoảng cách lên trên tính từ mặt đất |
| Mặt đất chuẩn | y = 148 | |
| Vạch chết rơi hố | y = 196 (16 px dưới mép màn hình) | Đáy hurtbox qua vạch → `PIT` |
| Vị trí ngang nhân vật | x = 64 | Cố định trên màn hình |
| Vùng nhìn trước | 256 px (màn 320) – 336 px (màn 400) | Luật công bằng tính theo **256 px** |

## 2. Nhảy

| Thông số | Tên code | Giá trị |
|---|---|---|
| Trọng lực | `gravity` | 1000 px/s² |
| Vận tốc nhảy ban đầu | `jump_velocity` | 260 px/s |
| Hệ số trọng lực khi giữ (đang bay lên) | `hold_gravity_scale` | 0.6 |
| Thời gian giữ tối đa có tác dụng | `max_hold_time` | 0.22 s (13 tick) |
| Hệ số trọng lực khi rơi | `fall_gravity_scale` | 1.15 |
| Vận tốc rơi tối đa | `max_fall_speed` | 420 px/s |
| Coyote time | `coyote_time` | 0.08 s (5 tick) |
| Jump buffer | `jump_buffer` | 0.12 s (7 tick) |
| Vận tốc nảy khi đạp | `stomp_bounce_velocity` | 220 px/s |
| Thời gian giữ tối đa khi nảy | `stomp_max_hold_time` | 0.13 s (8 tick) |

Nhảy kích hoạt **khi chạm xuống** (touch down), không phải khi thả. "Giữ" tính từ lúc chạm xuống tới lúc thả. Input được ghi nhận ở **tick vật lý tiếp theo** — chi tiết ở [input/hiển thị/tất định](08-input-rendering-determinism.md).

Vì sao rơi nhanh hơn lên (1.15): cú nhảy "chắc tay", không lơ lửng. Vì sao giảm trọng lực khi giữ: độ cao biến thiên liên tục theo thời gian giữ → điều khiển tinh hơn.

### Kết quả (mô phỏng theo tick 60 Hz)

| Giữ | Độ cao đỉnh (chân) | Thời gian bay | Tầm xa @160 | @200 | @250 | @300 px/s |
|---|---|---|---|---|---|---|
| Chạm (0 tick) | **31.7 px** | 0.50 s | 80 | 100 | 125 | 150 |
| 4 tick | 38.1 px | 0.55 s | 88 | 110 | 138 | 165 |
| 8 tick | 43.4 px | 0.58 s | 93 | 117 | 146 | 175 |
| Tối đa (13 tick) | **48.6 px** | 0.63 s | 101 | 127 | 158 | 190 |
| Nảy khi đạp, không giữ | 22.4 px | 0.42 s | | | | |
| Nảy khi đạp, giữ tối đa | 32.0 px | 0.52 s | | | | |

Hàm tích phân dùng trong game và validator phải **giống hệt nhau** (`runner/physics/jump_physics.gd`) — test đảm bảo bảng trên khớp ±0.5 px.

## 3. Tốc độ chạy

### 3.1 Tốc độ gốc theo đảo
Mỗi đảo khai báo `speed_start` và `speed_end`. Trong đảo, tốc độ gốc tăng tuyến tính theo tiến độ:
```
base_speed = lerp(island.speed_start, island.speed_end, progress_in_island)     (px/s)
```
- Đảo kế tiếp bắt đầu bằng tốc độ kết thúc của đảo trước (tốc độ **không tụt**).
- Đoạn biển giữ nguyên tốc độ kết thúc của đảo trước.
- **Trần tốc độ gốc: 300 px/s.**
- Vì sao theo đảo thay vì theo tổng quãng đường (D-018): công thức theo tổng quãng đường cũ bão hoà ở 4.500 m, sau đó tốc độ do kẹp quyết định; khai báo theo đảo cho người thiết kế kiểm soát trực tiếp nhịp từng đảo.

### 3.2 Tốc độ hiệu dụng
```
speed = base_speed × modifiers.speed_mult        speed_mult ∈ [1.0, 1.5]
```
- `speed_mult > 1` chỉ đến từ hiệu ứng **lao tốc**, luôn kèm bảo vệ toàn phần (bất biến E1 ở [items](../01-game-design/04-items-and-powerups.md#5-bất-biến-của-hiệu-ứng)). Tốc độ hiệu dụng tối đa 450 px/s.
- **Không có hiệu ứng nào làm chậm** (`speed_mult < 1`) — vì chunk chỉ được kiểm định trong khoảng tốc độ của nó; chậm hơn có thể làm hố không còn nhảy qua được.
- Hết lao tốc: tốc độ giảm về tốc độ gốc trong 0.5 s, kèm 1.0 s bảo vệ.
- **Mọi quyết định sinh chunk/item dùng `base_speed`, không dùng tốc độ hiệu dụng** (D-021).

### 3.3 Bảng tốc độ — hành trình phát hành đề xuất
Theo đề xuất cho Q-06 ([run & stages §2](../01-game-design/02-run-journey-and-stages.md#2-hành-trình-content-pack-one-piece)):

| Đảo | Dài | Tốc độ | Thời gian (ước tính) |
|---|---|---|---|
| Foosha | 800 m | 140 → 160 | ~85 s + biển ~30 s |
| Orange Town | 1.000 m | 160 → 185 | ~93 s + ~26 s |
| Baratie | 1.000 m | 185 → 205 | ~82 s + ~23 s |
| Arlong Park | 1.200 m | 205 → 230 | ~88 s + ~21 s |
| Loguetown | 1.200 m | 230 → 255 | ~79 s + ~19 s |
| Alabasta | 2.000 m | 255 → 300 | ~116 s |
| **Tổng** | | | **~11 phút** |

Khi chạy thử Alabasta độc lập ở M3 (run bắt đầu tại Alabasta): **160 → 230 px/s**, ~2.8 phút.

## 4. Công bằng: thời gian phản ứng

### 4.1 Định nghĩa
**Thời gian phản ứng** của một mối nguy = thời gian từ lúc nó **bắt đầu nhận biết được** tới lúc nó chạm hurtbox người chơi nếu người chơi không làm gì:
- "Nhận biết được" = hitbox vào vùng nhìn trước (mép phải màn hình 320 px), **hoặc** tín hiệu báo trước bắt đầu (bóng đổ, dấu "!", bọt nước...) — lấy thời điểm sớm hơn.
- Tính với chuyển động thật của mối nguy (đứng yên, lao tới sau khi kích hoạt, bay, rơi...).

### 4.2 Luật (D-019)
| Luật | Giá trị |
|---|---|
| Thời gian phản ứng tối thiểu (trạng thái thường) | **0.70 s** |
| Trần tốc độ tiếp cận (tốc độ người chơi + tốc độ riêng của vật về phía người chơi) | **365 px/s** (= 256 px ÷ 0.70 s) |
| Báo trước tối thiểu | theo bảng ở [obstacles/enemies §3](../01-game-design/08-obstacles-enemies-npc.md#3-báo-trước-telegraph) |

Hệ quả: ở tốc độ gốc 300 px/s, kẻ địch lao tới chỉ được có tốc độ riêng ≤ 65 px/s; vật tĩnh có 256/300 = 0.85 s. Kẻ địch dùng `CHARGER` có lợi: đứng yên lúc mới hiện (người chơi đã thấy nó), chỉ lao tới sau khi kích hoạt.

Vì sao 0.70 s: thời gian phản xạ thị giác của người ~0.25 s, cộng thời gian quyết định và thời gian lấy đà trước vật (~0.2 s). Khủng long Chrome ở tốc độ tối đa cho khoảng 0.7 s.

Trong trạng thái lao tốc (tới 450 px/s) luật này không áp dụng vì người chơi được bảo vệ toàn phần.

## 5. Hitbox, hurtbox, dung sai

| Đối tượng / thông số | Giá trị | Ghi chú |
|---|---|---|
| Hurtbox nhân vật (dạng thường) | 10×20 px, đáy giữa = chân | Hình vẽ ~14×24 |
| Hurtbox dạng biến hình | × `size_mult` | Biến hình được bảo vệ khỏi `CONTACT` (E2) nên kích thước không gây chết oan |
| Hitbox chướng ngại vật | Hình vẽ thu vào 2 px mỗi bên và 2 px phía trên | Ghi trong `ObstacleData.hitbox` |
| Vùng nhặt item | Hurtbox nở thêm 4 px mỗi phía | |
| Dung sai đáp mép | ≥ 2 px chồng lên mặt đất | |
| Tự bước lên bậc | ≤ 4 px | |
| Corner correction | ≤ 6 px | > 6 px → `WALL` |
| Dung sai đạp | Đáy hurtbox tick trước ≤ đỉnh hitbox + 4 px | |
| i-frames sau vỡ khiên | 0.6 s | |
| i-frames lúc vào/ra biến hình | suốt animation + 0.5 s sau khi ra | |
| Bảo vệ sau khi hết lao tốc | 1.0 s | |
| Ngưỡng Perfect | khoảng hở nhỏ nhất ≤ 4 px (Usopp 6 px) | Định nghĩa ở [scoring](../01-game-design/05-scoring-progression-meta.md#3-perfect-jump--định-nghĩa-chính-xác) |

## 6. Giới hạn kích thước chướng ngại vật

Giới hạn **hitbox** (không phải hình vẽ). Validator là thẩm quyền cuối cùng; bảng này là hướng dẫn để thiết kế không phí công.

| Loại | Cao | Rộng | Cách vượt dự kiến |
|---|---|---|---|
| `ground_low` | 6–18 | 8–24 | Chạm |
| `ground_tall` | 28–40 | 8–24 | Giữ |
| `ground_wide` | 6–16 | 32–64 | Giữ, canh sớm |
| `gap` | — | 24 → 0.85 × tầm xa tối đa ở `speed_min` của chunk | Nhảy |
| `terrain_step` lên | bội số 8, tối đa 24 | — | Chạm (24 < 31.7) |
| `terrain_step` xuống | tối đa 48 | — | Chạy xuống |
| `air` dải thấp | đáy cao 22–28 px so với mặt đất | 8–16 | Chạy bên dưới |
| `air` dải cao | đáy cao 34–44 px | 8–16 | Chạy bên dưới; nhảy cao bị phạt |
| `hazard` quét đất | ≤ 20 | — | Chạm |

Vùng đệm: **48 px đầu và 48 px cuối** mỗi chunk là mặt đất phẳng ở độ cao entry/exit, không có vật nguy hiểm, không có điểm kích hoạt. Vì: hai chunk hợp lệ ghép lại vẫn hợp lệ.

## 7. Validator chunk

Mục tiêu: chứng minh **tồn tại** cách vượt qua chunk ở trạng thái thường, cách đó **người làm được**, và chunk tuân thủ luật công bằng.

### 7.1 Mô phỏng
Với mỗi tốc độ kiểm tra `s ∈ {speed_min, (speed_min+speed_max)/2, speed_max}` của chunk:
1. Trạng thái mô phỏng: người chơi (vị trí, vận tốc dọc, trên đất/trên không, coyote, tick) **và mọi vật có hành vi** (trạng thái vòng đời, vị trí) — vật chuyển động được mô phỏng bằng đúng code hành vi của game, kích hoạt theo vị trí người chơi.
2. Vật `PATROL` có pha ngẫu nhiên: kiểm tra 4 pha (0, ¼, ½, ¾ chu kỳ); tất cả phải qua được.
3. Tại mỗi tick khi được phép nhảy, rẽ nhánh: **không nhảy** hoặc **nhảy với thời gian giữ k ∈ {0, 4, 8, 13} tick**.
4. Nhánh chết bị loại; ghi nhớ trạng thái đã duyệt để không bùng nổ tổ hợp.
5. Thành công khi tới cuối chunk còn sống. **Không** dùng đạp, khiên, nhảy đôi hay item để chứng minh.

### 7.2 Tiêu chí "người làm được"
- Mỗi lần nhảy cần thiết trên đường thành công có **cửa sổ thời điểm bấm** ≥ **4 tick (≈ 67 ms)** ở `speed_max`. 2–3 tick → cảnh báo; ≤ 1 tick → lỗi.
- Không yêu cầu hai lần bấm cách nhau < 0.25 s.

### 7.3 Luật công bằng
- Mọi mối nguy có thời gian phản ứng ≥ 0.70 s (mục 4) ở `speed_max`.
- Tốc độ tiếp cận ≤ 365 px/s.
- Báo trước đủ thời gian tối thiểu theo hành vi.

### 7.4 Kiểm tra khác
- Item `safe` chạm được trên một đường thành công; `risky` chạm được trên ít nhất một đường — nếu không: cảnh báo.
- Không item nào chồng lên hitbox nguy hiểm.
- `entry_height`/`exit_height` khớp; vùng đệm 48 px sạch.
- `NoForegroundZone` bao phủ vùng có vật nguy hiểm.

### 7.5 Không do validator kiểm tra
Trạng thái có hiệu ứng (biến hình, lao tốc, nhảy cao hơn...) **không** được validator mô phỏng. Thay vào đó, `ContentRegistry` kiểm tra mọi item/nội tại tuân thủ các **bất biến hiệu ứng** E1–E4 — đảm bảo mọi hiệu ứng chỉ làm người chơi an toàn hơn so với trạng thái thường đã được kiểm định.

### 7.6 Chạy
- Trong editor: lệnh debug "Validate all chunks".
- Dòng lệnh: `godot --headless --path game -s res://runner/validation/validate_all.gd` → mã thoát ≠ 0 nếu có lỗi.
- Bắt buộc khi: thêm/sửa chunk, sửa hành vi, đổi bất kỳ thông số nào ở mục 2–6.

## 8. Sinh chunk lúc chạy — kỹ thuật

Luật thiết kế ở [run & stages §5.1](../01-game-design/02-run-journey-and-stages.md#51-chọn-chunk-khi-chạy).
- `ChunkSpawner` dựng trước tới **+2 màn hình**, xoá chunk đã qua **-1 màn hình**.
- Chuỗi chunk là **hàm của (seed, quãng đường)**: lọc theo `base_speed` tại vị trí đầu chunk (không phải tốc độ hiệu dụng), chọn bằng `rng.chunks`. Vì: hai người cùng seed luôn gặp cùng chuỗi chunk dù ăn item khác nhau (D-021).
- Vật cụ thể và tham số ngẫu nhiên của hành vi (pha tuần tra) quyết định lúc dựng chunk, bằng `rng.chunks`, theo thứ tự slot cố định.
- Item quyết định lúc dựng chunk bằng `rng.items`; giới hạn số lượng tính theo **số đã sinh**, không theo số đã nhặt. Trái cụ thể khi ăn: `rng.fruits`.
- Trang trí, NPC: `rng.cosmetic`.

## 9. Camera

| Thông số | Giá trị |
|---|---|
| Theo ngang | Khoá: nhân vật luôn ở x = 64 |
| Theo dọc | Chỉ theo **độ cao mặt đất** (không theo cú nhảy), làm mượt 0.25 s |
| Rung màn hình | Biên độ tối đa 2 px, nguyên pixel; tắt được |
| Hit-stop | Perfect: 2 tick; đạp: 3 tick; vỡ khiên: 4 tick; chết: 6 tick |
