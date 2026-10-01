# Công cụ và quy trình làm việc

## 1. Phần mềm cần cài

| Phần mềm | Phiên bản | Dùng để |
|---|---|---|
| Godot | 4.x stable (khoá phiên bản cụ thể ở M0, ghi decision log) | Engine; cần ≥ 4.3 để có `Parallax2D`, `TileMapLayer` |
| Git + Git LFS | mới nhất | Quản lý phiên bản, file nhị phân |
| Python 3 + `pillow`, `numpy` | ≥ 3.10 | Script trong `tools/` |
| Aseprite | mới nhất | Vẽ, animation, xuất sprite sheet |
| Audacity | mới nhất | Xử lý âm thanh |
| (Android) Android SDK + JDK theo hướng dẫn export của Godot | | Từ M3 để test máy thật |

Plugin Godot (trong `game/addons/`, ghi phiên bản vào decision log khi thêm):
- **gdUnit4** — test.
- **Aseprite Wizard** — import .aseprite (tuỳ chọn, quyết định ở M2).

## 2. Thiết lập repo (M0)

```bash
git init
git lfs install
```
`.gitattributes`:
```
*.png       filter=lfs diff=lfs merge=lfs -text
*.jpg       filter=lfs diff=lfs merge=lfs -text
*.aseprite  filter=lfs diff=lfs merge=lfs -text
*.ogg       filter=lfs diff=lfs merge=lfs -text
*.wav       filter=lfs diff=lfs merge=lfs -text
*.ttf       filter=lfs diff=lfs merge=lfs -text
```
`.gitignore`:
```
game/.godot/
game/export/
*.import.tmp
__pycache__/
.DS_Store
art-source/processed/
```
(`art-source/processed/` là đầu ra tạo lại được từ raw — không cần lưu.)

## 3. Cấu hình project Godot (M0)

| Mục | Giá trị | Vì sao |
|---|---|---|
| Display → Window → Size → Viewport | 320 × 180 | D-014 |
| Window override (chỉ editor) | 1280 × 720 | Xem rõ khi dev |
| Stretch → Mode | `viewport` | Pixel-perfect |
| Stretch → Aspect | `expand` | Màn hình dài thấy thêm phía trước |
| Stretch → Scale Mode | `integer` | Không méo pixel |
| Rendering → Textures → Default Texture Filter | `Nearest` | Pixel sắc |
| Rendering → 2D → Snap 2D Transforms/Vertices to Pixel | bật | Không lệch nửa pixel |
| Physics → Common → Physics Ticks per Second | 60 | Tick gameplay |
| Physics → Common → Max Physics Steps per Frame | 8 | |
| GDScript → Warnings → Untyped Declaration | Error | Bắt buộc kiểu tĩnh |
| Orientation (mobile) | Landscape | |

Lưới UI 640×360 (D-017): UI nằm trong `CanvasLayer` riêng render qua `SubViewport` 640×360 phóng nguyên lần — chi tiết làm ở M4.

## 4. Script trong `tools/`

| Script | Làm gì | Milestone |
|---|---|---|
| `pixelize.py` | Ảnh AI → pixel art thật ([pipeline](../02-art/05-ai-image-pipeline.md)) | M0 |
| `extract_palette.py` | Trích bảng màu `.gpl` từ ảnh tham khảo | M0 |
| `export_aseprite.sh` | Xuất mọi .aseprite → sprite sheet + JSON vào đúng thư mục content | M2 |
| `check_layers.py` | Quét `game/shared` và `game/runner` tìm tham chiếu sai chiều (`res://runner` trong shared, `res://content/` trong runner...) | M1 |
| `check_ip_names.py` | Quét `game/shared` và `game/runner` tìm tên IP (danh sách từ khoá trong script: luffy, zoro, gomu, marine...) | M1 |
| `check_localization.py` | Key dùng trong code/dữ liệu ↔ key trong CSV, đủ ngôn ngữ | M4 |

Godot headless:
```bash
godot --headless --path game -s res://runner/validation/validate_all.gd     # validator chunk
godot --headless --path game -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests   # test
```
(Lệnh gdUnit4 kiểm tra lại theo phiên bản plugin khi cài.)

## 5. Chế độ debug (NFR-QA-01)

Chỉ có trong bản debug (`OS.is_debug_build()`), không có trong bản release.

| Chức năng | Phím (PC) | Ghi chú |
|---|---|---|
| Hiện/ẩn overlay debug | F1 | FPS, tốc độ, quãng đường, đảo/đoạn/chunk hiện tại, seed |
| Hiện hitbox/hurtbox | F2 | |
| Bất tử | F3 | |
| Tốc độ ×0.5 / ×1 / ×2 thời gian | F4 | Xem chậm để chỉnh |
| Nhảy tới đoạn tiếp theo | F5 | |
| Nhập seed | F6 | |
| Thêm item bất kỳ | F7 | Menu chọn |
| Ghi/phát lại input của run | F8/F9 | Tái hiện lỗi |
| Trên điện thoại | Chạm 4 ngón | Mở menu debug |

Log vị trí chết theo chunk id ra file `user://debug/deaths.csv` để phân tích độ khó.

## 6. Vòng làm việc hằng ngày

1. Chọn việc trong milestone hiện tại ([milestones](../00-overview/03-milestones.md)).
2. Tạo nhánh `ms<N>/<việc>`.
3. Đọc tài liệu liên quan; nếu việc mâu thuẫn tài liệu → cập nhật tài liệu/decision log trước.
4. Làm; chạy test + validator + script kiểm tra.
5. Commit nhỏ; gộp vào `main` khi chạy được.
6. Cuối milestone: chạy checklist hoàn thành, cập nhật tài liệu với số liệu thật (thời gian, thông số).

## 7. Test trên thiết bị

- Từ M3: build Android debug, cài qua USB (*Remote Debug* của Godot).
- Máy tham chiếu: 1 Android tầm trung (ghi model vào decision log), 1 iPhone (từ M8).
- Kiểm tra mỗi milestone: FPS, độ trễ chạm (chạm → nhảy phải trong cùng tick), tỉ lệ màn hình.
