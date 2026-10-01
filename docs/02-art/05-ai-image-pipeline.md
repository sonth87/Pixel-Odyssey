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

Code: `tools/pixelize.py` (dòng lệnh), `tools/pixel_art.py` (dò lưới, thu nhỏ, xoá nền, màu), `tools/sprite_frame.py` (đặt khung). Cài: `pip install pillow numpy`.

### 5.1 Đầu vào / đầu ra
```
python tools/pixelize.py <ảnh|thư mục> [tuỳ chọn]

--frame 64x64        khung đích (64x64, 128x64, 96x96, 128x128); 'none' = cắt sát hình (nền, đồ vật)
--grid <n>           ép kích thước ô pixel của ảnh gốc (mặc định tự dò)
--key auto|#FF00FF   màu nền; auto = màu phổ biến nhất ở viền ảnh
--tolerance 40       khoảng cách màu (RGB) để loang xoá nền từ mép ảnh
--palette <f.gpl>    ép về bảng màu (bảng con của nhân vật/đoạn)
--max-colors 16      khi không có bảng màu: gom về tối đa n màu
--strip <n>          ảnh là dải n frame ngang → n frame riêng
--despeckle <n>      xoá cụm pixel rời ≤ n pixel (mặc định tắt — tránh xoá nhầm khói, tia sáng)
--preview 8          lưu ảnh xem trước phóng to 8× (0 = không)
--out <thư mục>      mặc định art-source/processed/<đường dẫn tương ứng trong art-source/raw>
```
Đầu ra: `<tên>.png` (hoặc `<tên>_f1.png`… với dải frame) + `<tên>_preview.png`. Mã thoát ≠ 0 nếu có cảnh báo.

### 5.2 Các bước xử lý
1. **Dò lưới**: với mỗi kích thước ô ứng viên (3–64 px, bước 0.25, sau đó tinh chỉnh bước 0.02), tìm độ lệch lưới bằng cách khớp "răng lược" với các cạnh màu trong ảnh, rồi đo **sai số dựng lại** (lấy màu giữa mỗi ô, phóng lại, so với ảnh gốc) — chỉ đo trong vùng có hình, không đo nền trống. Ô bằng ước số của ô thật cũng dựng lại tốt, ô bằng bội số thì không → chọn **ô lớn nhất vẫn dựng lại tốt**. Chạy được với ô không nguyên (ảnh 1440 px của Zoro: ô 22.46 px).
2. **Thu nhỏ**: mỗi ô → một pixel, lấy **trung vị** màu ở nửa giữa ô (bỏ viền ô để tránh màu lẫn).
3. **Xoá nền**: loang từ mép ảnh với `--tolerance`; thêm vào đó xoá các "lỗ" kín bên trong hình **chỉ khi gần như trùng màu nền** (sai khác ≤ 12) — để khe giữa các chi tiết (giữa kiếm, giữa tay và thân) được xoá mà màu sáng của hình (da, áo trắng) vẫn giữ.
4. **Ép màu**: theo khoảng cách CIELAB về bảng màu; không có bảng → gom về `--max-colors` màu.
5. **Dọn** (tuỳ chọn): xoá cụm pixel rời nhỏ.
6. **Đặt khung**: chân ở hàng đáy, thân ở giữa (cột trung tâm của 4 hàng pixel thấp nhất). Với `--strip`: dùng **cùng một** phép căn của frame đầu cho mọi frame để giữ chuyển động tương đối.
7. **Báo cáo**: kích thước ô, độ lệch, kích thước gốc, điểm khớp, sai số dựng lại, số màu trước/sau, cảnh báo nếu tràn khung hoặc dò lưới không chắc chắn.

**Kết quả kiểm tra trên 23 ảnh tham khảo** (M0): mọi ảnh nhân vật đơn ra đúng lưới 64×64 (ô 16 px hoặc 22.46 px), sai số dựng lại ≤ 0.3/255. Ảnh tham khảo có vạch mặt đất đứt nét màu sáng — vạch này không bị xoá với `--tolerance 40` (ảnh AI nền magenta không có vạch này).

### 5.3 Bảng màu: `tools/extract_palette.py`
```
python tools/extract_palette.py [--input assets/charactors] [--out art-source/palettes] [--merge 6] [--min-count 3]
```
Lấy màu từ các ảnh **một nhân vật** (bỏ qua ảnh nhóm vì lưới không nguyên tạo màu pha ở viền), gộp màu gần nhau (ΔE < `--merge`), bỏ màu quá hiếm. Tạo `master.gpl` (hợp của mọi nhân vật) và `characters/<id>.gpl` (mỗi màu được ép về màu gần nhất trong master). Bảng con hiện có 14–28 màu vì gộp cả ảnh biến thể (`nami_money`, `luffy_piston`…); rút gọn tay trong Aseprite khi làm từng nhân vật.

### 5.4 Khi nào script không đủ
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
