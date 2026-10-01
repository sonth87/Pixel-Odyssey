# Quy trình: ảnh AI → pixel art dùng được trong game

## 1. Vì sao cần quy trình này

Ảnh AI (Gemini, ChatGPT) **trông như** pixel art nhưng thường là **pixel giả**:
- Ô pixel không đều nhau (ô 15 px cạnh ô 17 px), lệch lưới.
- Cạnh ô bị mờ/lẫn màu (anti-aliasing), có nhiễu màu li ti — một mảng "đỏ" thực ra là 30 sắc đỏ gần nhau.
- Nền không trong suốt.
- Ảnh to (1024 px) trong khi game cần 64×64.
- Các frame của cùng một animation lệch nhau (vị trí chân, kích thước).

Đưa thẳng ảnh này vào game sẽ thấy nhoè, viền bẩn, nhân vật rung. Quy trình dưới đây biến nó thành **pixel art thật**: đúng lưới, đúng bảng màu, nền trong suốt, đúng khung, đúng tâm.

## 2. Tổng quan

```
① Gen ảnh (Gemini / ChatGPT)          → art-source/raw/...           (+ .prompt.md)
② pixelize.py (tự động)               → art-source/processed/...
③ Aseprite (sửa tay + animation)      → art-source/aseprite/<id>.aseprite
④ Xuất sprite sheet + JSON            → game/content/<pack>/.../sprites/
⑤ Godot import (Nearest, không nén mất dữ liệu) → dùng trong game
```

## 3. Công cụ

| Công cụ | Dùng để | Bắt buộc? | Ghi chú |
|---|---|---|---|
| **Gemini** (model ảnh "Nano Banana") | Gen ảnh, đặc biệt là **chỉnh sửa** từ ảnh có sẵn → giữ nhân vật nhất quán | Một trong hai | Tốt nhất cho frame animation (O-EDIT) |
| **ChatGPT** (GPT image) | Gen ảnh, dải nhiều frame | Một trong hai | |
| **Python 3 + Pillow + NumPy** | Chạy `tools/pixelize.py` | Có | Cài: `pip install pillow numpy` |
| **Aseprite** | Sửa pixel, làm animation, tag, xuất sprite sheet | **Rất nên có** | Trả phí một lần (~20 USD), hoặc tự build từ mã nguồn miễn phí. Chuẩn công nghiệp cho pixel art, có dòng lệnh để xuất tự động |
| Pixelorama | Thay thế miễn phí cho Aseprite | Tuỳ chọn | Làm bằng Godot, đủ dùng nhưng kém tiện hơn |
| LibreSprite | Thay thế miễn phí (nhánh cũ của Aseprite) | Tuỳ chọn | Không có một số tính năng mới |
| **Godot 4** | Engine | Có | |
| Plugin Godot "Aseprite Wizard" | Import file .aseprite thẳng thành SpriteFrames/AnimationPlayer | Tuỳ chọn (đề xuất) | Tự động hoá bước ④–⑤; cần đường dẫn tới Aseprite CLI |
| Lospec (trang bảng màu pixel art) | Tham khảo bảng màu | Tuỳ chọn | Bảng màu của dự án đã có từ ảnh tham khảo |

Có cần cả Aseprite **và** Godot không? **Có** — vai trò khác nhau: Aseprite là nơi *vẽ và làm animation*; Godot là nơi *chạy game*. Godot không có công cụ vẽ pixel tốt.

## 4. Bước ① — Gen ảnh

1. Mở [prompt library](06-prompt-library.md) và file đặc tả tương ứng, ghép prompt.
2. Đính kèm ảnh tham chiếu theo bảng ở prompt library.
3. Gen 3–4 biến thể, chọn bản tốt nhất. Tiêu chí chọn theo thứ tự: **dáng/tư thế đúng** > tỉ lệ đúng > màu đúng > chi tiết. (Màu và chi tiết sửa được dễ; dáng sai thì phải gen lại.)
4. Lưu ảnh gốc **không chỉnh sửa** vào:
   ```
   art-source/raw/<nhóm>/<id>/<tag>/<YYYYMMDD>_<n>.png
   art-source/raw/<nhóm>/<id>/<tag>/<YYYYMMDD>_<n>.prompt.md
   ```
   Ví dụ `art-source/raw/characters/luffy/idle/20261005_1.png`.

**Chiến lược để các frame nhất quán** (vấn đề khó nhất khi dùng AI):
- Gen một frame `idle` thật chuẩn trước, xử lý xong, duyệt.
- Mọi tư thế khác làm bằng **O-EDIT** từ frame đã duyệt (phóng to 16× nearest trước khi gửi).
- Với chu kỳ chạy: dùng AI cho 2–3 **tư thế chính** (key pose), các frame xen giữa vẽ tay trong Aseprite bằng onion skin. Nhân vật cao 24 px nên vẽ tay một frame chỉ mất vài phút.
- Chấp nhận thực tế: AI làm ~60–70% công việc, phần còn lại là sửa tay.

## 5. Bước ② — `tools/pixelize.py`

Script tự động, viết ở M0. Đặc tả hành vi:

### 5.1 Đầu vào / đầu ra
```
python tools/pixelize.py <input.png|thư mục> [tuỳ chọn]

--frame 64x64           khung đích (64x64, 128x64, 96x96, 128x128); 'none' cho nền/đồ vật
--grid auto|<n>         kích thước ô pixel trong ảnh gốc; auto = tự dò
--key auto|#FF00FF      màu nền cần xoá; auto = lấy màu ở 4 góc
--palette <file.gpl>    ép về bảng màu (bảng con của nhân vật/đoạn)
--max-colors <n>        nếu không có bảng màu: gom về tối đa n màu
--strip <n>             ảnh là dải n frame → cắt thành n frame riêng
--out <thư mục>         mặc định art-source/processed/<cùng đường dẫn>
```

### 5.2 Các bước xử lý
1. **Dò lưới**: thử các kích thước ô (ví dụ 8–40 px), với mỗi kích thước thu nhỏ bằng *nearest* rồi phóng lại, đo sai khác so với ảnh gốc; kích thước có sai khác nhỏ nhất là lưới thật. Kiểm tra cả độ lệch (offset) 0..n-1 của lưới. (Cách này đã được dùng để đo ảnh tham khảo: Luffy lưới 16 px → 64×64.)
2. **Thu nhỏ**: mỗi ô → một pixel, lấy màu **trung vị/phổ biến nhất** ở vùng giữa ô (bỏ viền ô để tránh màu lẫn).
3. **Xoá nền**: *flood fill từ các mép ảnh* với màu nền ± sai số → trong suốt. Không thay toàn cục (để không xoá nhầm pixel bên trong có màu gần nền, ví dụ da sáng gần màu kem).
4. **Ép bảng màu**: mỗi pixel → màu gần nhất trong bảng (khoảng cách màu theo cảm nhận, ví dụ CIELAB). Không có bảng → gom cụm về `max-colors`.
5. **Dọn**: alpha chỉ 0/255; xoá pixel đơn lẻ không nối với hình chính (nhiễu).
6. **Đặt khung**: cắt sát hình, đặt vào khung đích sao cho **chân ở hàng đáy, thân ở giữa** (tìm cột trung tâm của 4 hàng pixel thấp nhất). Với `--strip`: dùng **cùng một** phép căn cho mọi frame dựa trên frame đầu để giữ chuyển động tương đối.
7. **Báo cáo**: in ra lưới dò được, số màu trước/sau, kích thước hình, cảnh báo nếu hình vượt khung hoặc dò lưới không chắc chắn (sai khác lớn).

### 5.3 Khi nào script không đủ
- Lưới trong ảnh AI méo không đều → dò lưới sai → kết quả vỡ. Cách xử lý: thử `--grid` bằng tay; hoặc mở ảnh gốc trong Aseprite, *Sprite → Sprite Size* thu nhỏ nearest, rồi sửa tay.
- Nhân vật quá chi tiết so với 24 px → phải đơn giản hoá bằng tay.

## 6. Bước ③ — Aseprite

### 6.1 Cấu trúc file
- **Một file .aseprite cho mỗi nhân vật / mỗi dạng biến hình / mỗi kẻ địch**: `art-source/aseprite/characters/luffy.aseprite`, `luffy_gear4.aseprite`.
- Canvas = kích thước khung (64×64).
- Mỗi animation là một **tag** đặt tên đúng [bảng trạng thái](02-character-animation-spec.md) (`idle`, `run`, `jump_rise`...). Tag có hướng *Forward*; animation lặp hay không do dữ liệu trong game quyết định.
- Layer: `body` (chính); thêm layer `fx` nếu có hiệu ứng vẽ liền sprite. Không để layer ẩn chứa rác.
- Bật *Palette* = bảng con của nhân vật (`art-source/palettes/characters/<id>.gpl`).
- Thời lượng frame đặt theo FPS trong đặc tả (12 FPS ≈ 83 ms).

### 6.2 Việc cần làm trong Aseprite
1. *File → Import* các frame đã pixelize (hoặc kéo thả), xếp đúng thứ tự, đúng tag.
2. Bật **onion skin** để kiểm tra chuyển động; sửa chân về đúng hàng đáy.
3. Sửa pixel lỗi, làm silhouette rõ hơn, đồng nhất màu giữa các frame.
4. Vẽ frame xen giữa còn thiếu.
5. Chạy thử từng tag (phím Enter) ở 1× và 4×.
6. Chạy checklist ở [animation spec](02-character-animation-spec.md#5-checklist-duyệt-một-bộ-animation).

### 6.3 Nền tileable
- *View → Tiled Mode → Tile in X axis* để thấy mép trái/phải nối nhau; sửa đường nối trực tiếp.

## 7. Bước ④ — Xuất

Xuất tự động bằng dòng lệnh (script `tools/export_aseprite.sh`, viết ở M0/M2):
```
aseprite -b art-source/aseprite/characters/luffy.aseprite \
  --sheet game/content/onepiece/characters/luffy/sprites/luffy.png \
  --data  game/content/onepiece/characters/luffy/sprites/luffy.json \
  --format json-array --list-tags --sheet-type packed --trim-sprite=false
```
- **Không trim** frame nhân vật (giữ nguyên khung 64×64 để pivot đúng).
- Đồ vật tĩnh/nền: xuất PNG đơn.
- Nếu dùng plugin Aseprite Wizard: plugin đọc thẳng .aseprite, bước này tự động.

## 8. Bước ⑤ — Godot

Cấu hình project (làm một lần ở M0):
- *Rendering → Textures → Canvas Textures → Default Texture Filter* = **Nearest**.
- *Display → Window → Stretch*: Mode = `viewport`, Aspect = `expand` (chiều rộng mở rộng), Scale Mode = `integer`. Kích thước viewport 320×180.
- Import ảnh: *Compress Mode* = Lossless; *Mipmaps* = tắt.

Nhân vật: `AnimatedSprite2D` với `SpriteFrames` sinh từ sheet + JSON (bằng plugin hoặc script import của dự án); tên animation = tên tag. Pivot: `offset` sao cho điểm (32, 64) của khung trùng gốc node.

## 9. Âm thanh cho asset

Xem [audio](../03-audio/01-audio-spec.md) — quy trình gen/chỉnh âm tương tự (raw → xử lý → game).

## 10. Thời gian dự kiến (cập nhật sau M2 bằng số thật)

| Việc | Ước lượng |
|---|---|
| 1 frame nhân vật (gen + pixelize + sửa) | 10–20 phút |
| Bộ B1 một nhân vật (~40 frame) | 8–14 giờ |
| 1 lớp nền toàn cảnh | 1–2 giờ |
| 1 mảnh nền rời / 1 chướng ngại vật | 15–30 phút |
