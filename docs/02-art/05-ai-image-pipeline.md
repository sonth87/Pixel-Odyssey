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
③ Pixelorama (sửa tay + animation)    → art-source/pixelorama/<nhóm>/<id>.pxo
④ Xuất mỗi animation một dải PNG      → game/content/<pack>/<nhóm>/<id>/sprites/<dạng>/<tag>.png
   + tools/check_sprites.py kiểm tra
⑤ Godot tự dựng SpriteFrames từ các dải PNG → dùng trong game
```

**Định dạng trao đổi sprite** (D-029): mỗi animation là **một ảnh PNG dải ngang**, tên file = tên tag, các frame cùng kích thước xếp liền nhau từ trái sang phải. Số frame = chiều rộng ÷ chiều rộng khung. Vì: không phụ thuộc phần mềm vẽ (Pixelorama, Aseprite, LibreSprite đều xuất được), dễ xem bằng mắt, dễ kiểm tra tự động.

## 3. Công cụ

| Công cụ | Dùng để | Bắt buộc? | Ghi chú |
|---|---|---|---|
| **Gemini** (model ảnh "Nano Banana") | Gen ảnh, đặc biệt là **chỉnh sửa** từ ảnh có sẵn → giữ nhân vật nhất quán | Một trong hai | Tốt nhất cho frame animation (O-EDIT) |
| **ChatGPT** (GPT image) | Gen ảnh, dải nhiều frame | Một trong hai | |
| **Python 3 + Pillow + NumPy** | Chạy `tools/pixelize.py`, `tools/check_sprites.py` | Có | Cài: `pip install pillow numpy` |
| **Pixelorama** | Sửa pixel, làm animation (frame, tag, onion skin, tiled mode), xuất dải PNG | **Có** (D-029) | Miễn phí, mã nguồn mở, chạy trên Mac/Windows/Linux. File nguồn `.pxo`. Nhập được bảng màu `.gpl` |
| Aseprite / LibreSprite | Thay thế nếu sau này cần | Không | Định dạng dải PNG giữ nguyên nên đổi phần mềm không ảnh hưởng game |
| **Godot 4** | Engine | Có | |
| Lospec (trang bảng màu pixel art) | Tham khảo bảng màu | Tuỳ chọn | Bảng màu của dự án đã có từ ảnh tham khảo |

Có cần cả Pixelorama **và** Godot không? **Có** — vai trò khác nhau: Pixelorama là nơi *vẽ và làm animation*; Godot là nơi *chạy game*. Godot không có công cụ vẽ pixel tốt.

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
- Với chu kỳ chạy: dùng AI cho 2–3 **tư thế chính** (key pose), các frame xen giữa vẽ tay trong Pixelorama bằng onion skin. Nhân vật cao 24 px nên vẽ tay một frame chỉ mất vài phút.
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
- Lưới trong ảnh AI méo không đều → dò lưới sai → kết quả vỡ. Cách xử lý: thử `--grid` bằng tay; hoặc mở ảnh gốc trong Pixelorama, thu nhỏ ảnh (chế độ nội suy *Nearest*) về đúng kích thước gốc, rồi sửa tay.
- Nhân vật quá chi tiết so với 24 px → phải đơn giản hoá bằng tay.

## 6. Bước ③ — Pixelorama

### 6.1 Cấu trúc file
- **Một file `.pxo` cho mỗi nhân vật-dạng / mỗi kẻ địch**: `art-source/pixelorama/characters/luffy.pxo` (dạng thường), `luffy_gear4.pxo` (dạng biến hình, canvas 96×96).
- Canvas = kích thước khung (64×64 / 96×96...).
- Mỗi animation là một **tag** đặt tên đúng [bảng trạng thái](02-character-animation-spec.md) (`idle`, `run`, `jump_rise`...). Tag trong `.pxo` chỉ để làm việc cho tiện; game dùng tên file khi xuất (mục 7).
- Layer: `body` (chính); thêm layer `fx` nếu có hiệu ứng vẽ liền sprite. Không để layer ẩn chứa rác.
- Nhập bảng màu con của nhân vật (`art-source/palettes/characters/<id>.gpl`) và chỉ vẽ bằng bảng đó.
- FPS xem trước đặt theo đặc tả (chạy 12, đứng 6) — trong game FPS lấy từ dữ liệu, không từ file `.pxo`.

### 6.2 Việc cần làm trong Pixelorama
1. Mở/nhập các frame đã pixelize (mỗi ảnh một frame), xếp đúng thứ tự, gắn tag.
2. Bật **onion skin** để kiểm tra chuyển động; sửa chân về đúng hàng đáy.
3. Sửa pixel lỗi, làm silhouette rõ hơn, đồng nhất màu giữa các frame.
4. Vẽ frame xen giữa còn thiếu.
5. Chạy thử từng tag ở 1× và 4×.
6. Chạy checklist ở [animation spec](02-character-animation-spec.md#5-checklist-duyệt-một-bộ-animation).

### 6.3 Nền tileable
- Bật chế độ lặp ô (*Tile Mode*) theo trục ngang để thấy mép trái/phải nối nhau; sửa đường nối trực tiếp.

## 7. Bước ④ — Xuất dải PNG

Với mỗi tag: xuất dạng **spritesheet**, chỉ các frame của tag đó, **1 hàng**, không cắt viền (giữ nguyên khung để pivot đúng). Lưu vào:
```
game/content/<pack>/<nhóm>/<id>/sprites/<dạng>/<tag>.png
ví dụ  game/content/onepiece/characters/luffy/sprites/base/idle.png      (4 frame → 256×64)
       game/content/onepiece/characters/luffy/sprites/gear4/form_run.png (khung 96×96)
```
(Tên mục menu trong Pixelorama có thể khác nhẹ theo phiên bản: *File → Export → Spritesheet*, chọn khoảng frame theo tag, số hàng = 1.)

- Đồ vật tĩnh/nền: xuất PNG đơn.
- Sau khi xuất, chạy kiểm tra:
  ```
  python tools/check_sprites.py game/content/onepiece/characters/luffy/sprites/base --frame 64x64 \
         --palette art-source/palettes/characters/luffy.gpl
  ```
  Kiểm tra: chiều rộng chia hết cho khung, alpha chỉ 0/255, số màu và màu ngoài bảng, frame rỗng, chân chạm hàng đáy ở các animation trên mặt đất, tên file đúng dạng tag.

## 8. Bước ⑤ — Godot

Cấu hình project (làm một lần ở M0): xem [tooling §3](../05-technical/06-tooling-and-workflow.md#3-cấu-hình-project-godot-m0) — lọc ảnh *Nearest*, phóng nguyên lần, import *Lossless*, không mipmaps.

Nhân vật: `AnimatedSprite2D` với `SpriteFrames` **dựng tự động** từ thư mục `sprites/<dạng>/` (script import của dự án): mỗi file PNG → một animation cùng tên, cắt theo kích thước khung của `AnimationSet`. FPS và lặp/không lặp lấy từ bảng mặc định của [animation spec](02-character-animation-spec.md) (có thể ghi đè trong dữ liệu nhân vật). Pivot: `offset` sao cho điểm giữa đáy khung trùng gốc node.

## 9. Âm thanh cho asset

Xem [audio](../03-audio/01-audio-spec.md) — quy trình gen/chỉnh âm tương tự (raw → xử lý → game).

## 10. Thời gian dự kiến (cập nhật sau M2 bằng số thật)

| Việc | Ước lượng |
|---|---|
| 1 frame nhân vật (gen + pixelize + sửa) | 10–20 phút |
| Bộ B1 một nhân vật (~40 frame) | 8–14 giờ |
| 1 lớp nền toàn cảnh | 1–2 giờ |
| 1 mảnh nền rời / 1 chướng ngại vật | 15–30 phút |
