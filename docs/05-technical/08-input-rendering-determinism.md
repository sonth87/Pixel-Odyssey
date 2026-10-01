# Input, hiển thị, tính tất định

Tài liệu này quyết định **cảm giác điều khiển** và **độ mượt hình ảnh**, và cụ thể hoá D-027 (mô phỏng bằng số nguyên). Phải được duyệt trước khi viết code vật lý ở M1. Mọi giá trị là `ĐỀ XUẤT` cho tới khi đo trên máy thật ở M1.

## 1. Số nguyên cố định

### 1.1 Đơn vị
| Đại lượng | Đơn vị trong mô phỏng | Ghi chú |
|---|---|---|
| Vị trí | **subpixel** = 1/256 px (`SUB = 256`) | Lưu kiểu `int` (64-bit trong GDScript) |
| Vận tốc | subpixel / tick | |
| Gia tốc | subpixel / tick² | |
| Hệ số (`speed_mult`, `jump_mult`...) | phần 1024 (`1.5` → `1536`) | `giá_trị × hệ_số / 1024` |
| Quãng đường | subpixel, cộng dồn | mét = `quãng_đường / (16 × 256)` |
| Hitbox, hurtbox | px nguyên trong dữ liệu; nhân 256 khi so va chạm | |
| Trọng số ngẫu nhiên | số nguyên (dữ liệu `float` × 1000 khi nạp) | |

Vì sao 1/256: đủ mịn để tốc độ 140 px/s (2.33 px/tick) không bị làm tròn thô; phép chia cho 256 là phép dịch bit nhanh; số vẫn nhỏ hơn rất xa giới hạn `int`.

### 1.2 Quy đổi từ giá trị thiết kế
```
vận tốc   [subpx/tick]  = round(px_per_s × 256 / 60)
gia tốc   [subpx/tick²] = round(px_per_s2 × 256 / 3600)
```
Quy đổi chỉ làm **một lần khi nạp** `RunnerPhysicsConfig`; mô phỏng không bao giờ thấy số thực.

| Thông số ([physics §2](05-physics-collision-generation.md#2-nhảy)) | Thiết kế | Nguyên |
|---|---|---|
| `gravity` | 1000 px/s² | 71 |
| trọng lực khi giữ (×0.6) | 600 px/s² | 43 |
| trọng lực khi rơi (×1.15) | 1150 px/s² | 82 |
| `jump_velocity` | 260 px/s | 1109 |
| `max_fall_speed` | 420 px/s | 1792 |
| `stomp_bounce_velocity` | 220 px/s | 939 |
| Tốc độ 140 / 160 / 230 / 255 / 300 px/s | | 597 / 683 / 981 / 1088 / 1280 |
| Trần tiếp cận 365 / tốc độ tối đa có hiệu ứng 450 px/s | | 1557 / 1920 |

Bảng nhảy tính bằng số nguyên (khớp bảng số thực trong khoảng 0.3 px):

| Giữ | Đỉnh | Thời gian bay |
|---|---|---|
| 0 tick | 31.7 px | 30 tick |
| 4 tick | 38.0 px | 33 tick |
| 8 tick | 43.2 px | 35 tick |
| 13 tick | 48.3 px | 38 tick |
| Nảy khi đạp, giữ 0 / 8 tick | 22.4 / 31.9 px | |

Test M1-01 phải tái tạo đúng bảng này.

### 1.3 Quy tắc viết code mô phỏng
- **Không** `float`, `Vector2`, `delta`, `Time` trong mô phỏng. Dùng `int` và `Vector2i`.
- **Phép chia**: phép `/` giữa hai `int` trong GDScript **làm tròn về 0** (−7/2 = −3), không phải làm tròn xuống. Vận tốc đi lên là số âm → dùng hàm `fdiv()` (chia làm tròn xuống) của thư viện số nguyên cho mọi phép chia có thể âm. Có test riêng cho trường hợp âm.
- Thứ tự phép tính cố định (nhân trước, chia sau) để không mất độ chính xác.
- Nội suy tốc độ trong đảo: `speed = start + (end − start) × quãng_đường_trong_đảo / độ_dài_đảo` — toàn số nguyên.

### 1.4 Ngẫu nhiên
- Dùng `RandomNumberGenerator` của Godot (thuật toán PCG32, tất định theo seed trên mọi nền tảng), **chỉ** dùng `randi()` / `randi_range()`. Không dùng `randf()` trong mô phỏng.
- Chọn theo trọng số bằng tổng trọng số nguyên.
- Bốn luồng (`chunks`, `items`, `fruits`, `cosmetic`) có seed con suy ra từ seed run bằng một hàm băm cố định.

### 1.5 Ghi và phát lại
Bản ghi một run:
```
{ version, physics_hash, content_hash, seed, character_id,
  events: [ [tick, "press"], [tick, "release"], ... ] }
```
- `physics_hash`: băm của `RunnerPhysicsConfig` sau quy đổi; `content_hash`: băm danh sách chunk/obstacle của pack. Khác hash → bản ghi không phát lại được (báo rõ, không chạy sai).
- Phát lại = chạy mô phỏng không cần hình, đưa input theo tick. Kết quả (tick chết, quãng đường, điểm) phải trùng tuyệt đối.
- Dùng cho: tái hiện lỗi (F8/F9), test tất định, bóng ma kỷ lục, kiểm tra run trên server (M7).

## 2. Input

### 2.1 Quy tắc
| Quy tắc | Giá trị |
|---|---|
| Nhảy kích hoạt khi | **chạm xuống** (touch down / phím xuống / chuột xuống) |
| "Giữ" kéo dài tới | lúc nhấc ngón đó ra |
| Vùng chạm | toàn màn hình trừ vùng nút pause |
| Nhiều ngón | ngón đầu tiên quyết định; ngón khác bị bỏ qua khi ngón đầu còn giữ |
| PC | Space, ↑, W, chuột trái (cùng nghĩa); Esc / P = pause |
| Trong lúc đếm 3-2-1 sau pause | bỏ qua input; trạng thái giữ bị xoá |

### 2.2 Từ sự kiện tới tick
Sự kiện chạm đến **không đồng bộ** với tick vật lý. Cách xử lý:
1. `_input` / `_unhandled_input` chỉ **ghi** sự kiện vào hàng đợi (`press` / `release`), không xử lý gameplay.
2. Đầu mỗi tick vật lý, `InputCollector` lấy hết hàng đợi, chuyển thành trạng thái của tick đó (`pressed_this_tick`, `held`, `released_this_tick`) và ghi vào bản ghi run.
3. `JumpController` chỉ đọc trạng thái tick.

Nếu chạm và nhả trong cùng một tick (chạm rất nhanh) → vẫn tính một lần nhảy chạm (giữ 0 tick).

Độ trễ do tick tối đa 1 tick (16.7 ms), cộng độ trễ màn hình của máy.

### 2.3 Cấu hình Godot
| Cài đặt | Giá trị | Vì sao |
|---|---|---|
| `input_devices/pointing/emulate_mouse_from_touch` | `false` | Không nhận một chạm thành hai sự kiện |
| `input_devices/pointing/emulate_touch_from_mouse` | `false` | Xử lý chuột riêng cho PC |
| Gộp sự kiện input (`Input.use_accumulated_input`) | `false` | Không gộp nhiều sự kiện trong một khung hình |
| Xả sự kiện input sớm trên Android (*agile event flushing*) | bật nếu phiên bản Godot có | Giảm độ trễ chạm |

Kiểm tra M1: đo độ trễ chạm → nhảy bằng quay phim 240 fps trên máy thật; mục tiêu ≤ 50 ms cảm nhận được.

## 3. Hiển thị

### 3.1 Tần số
- Mô phỏng: 60 tick/giây.
- **Vẽ hình khoá 60 khung/giây** (`Engine.max_fps = 60` + vsync) — `ĐỀ XUẤT`.
- Vì sao không dùng nội suy hình để vẽ 120 Hz: hình nội suy phải làm tròn về pixel nguyên, ở tốc độ 2.33 px/tick sẽ ra bước nhảy 1–2 px không đều giữa các khung → trông giật hơn. Với pixel art, 60 khung đều đặn mượt hơn 120 khung không đều.
- Rủi ro: màn hình 90 Hz không chia hết cho 60 → có thể thấy giật nhẹ. Kiểm tra trên máy thật ở M3; nếu có, thử yêu cầu hệ điều hành chuyển màn hình sang 60 Hz khi chơi.

### 3.2 Cuộn theo pixel nguyên
- Vị trí vẽ của mọi vật = `vị_trí_subpx >> 8` (làm tròn xuống), tính một lần mỗi tick.
- Mọi vật trên lớp gameplay dùng **cùng** độ lệch camera → không bao giờ lệch nhau 1 px giữa các vật.
- Lớp parallax: `độ_lệch_lớp = (camera_subpx × hệ_số_lớp_1024 / 1024) >> 8`. Lớp xa đi "từng bước" (ví dụ 1 px mỗi 4 tick ở tốc độ thấp) — đây là đặc trưng bình thường của game pixel art, chấp nhận.
- **Không** vẽ ở vị trí lẻ pixel, không làm mượt — giữ pixel art sắc nét (NFR-VS-01).
- Rung màn hình: dịch nguyên pixel.

### 3.3 Tỉ lệ màn hình
| Màn hình | Kích thước logic | Phần thừa |
|---|---|---|
| 16:9 | 320×180 | — |
| Dài hơn (19.5:9, 20:9) | rộng 321–400 × 180 | Thấy thêm phía trước (D-014) |
| Dài hơn 20:9 | 400×180 + **viền hai bên** | Viền tối, không thấy thêm |
| Cao hơn (16:10, 4:3 tablet) | 320 × 181–240 | Thêm **trời** ở phía trên |

- Mặt đất luôn ở y = 148 tính từ **đáy của vùng 180 px dưới cùng**; phần cao thêm nằm phía trên. Vì: vị trí gameplay không đổi trên mọi máy.
- Lớp trời (L0) vẽ cao 240 px để đủ cho 4:3.
- HUD bám góc **màn hình thật** và nằm trong vùng an toàn (tai thỏ) do hệ điều hành báo.
- Hệ số phóng = số nguyên lớn nhất vừa màn hình; phần dư nhỏ là viền tối.
- Luật công bằng (0.70 s) luôn tính trên 256 px nhìn trước — màn hình nào cũng ít nhất bằng chừng đó.

## 4. Ngân sách hiệu năng

| Hạng mục | Ngân sách mỗi tick (máy tầm trung) |
|---|---|
| Toàn bộ mô phỏng (người chơi, vật, va chạm, sinh chunk) | ≤ 4 ms |
| Vẽ | ≤ 8 ms |
| Dư cho hệ điều hành, âm thanh | phần còn lại của 16.7 ms |

Validator không chạy trong game (chạy lúc thiết kế / CI).

## 5. Test bắt buộc (M1)
- Bảng nhảy nguyên (mục 1.2) khớp từng tick.
- `fdiv` với số âm.
- Cùng seed + cùng bản ghi input chạy hai lần → băm trạng thái mỗi 60 tick trùng nhau.
- Phát lại bản ghi → cùng tick chết, quãng đường, điểm.
- So băm trạng thái giữa Mac và điện thoại Android cho cùng một bản ghi (kiểm tra thủ công ở M1, tự động hoá ở M7).
