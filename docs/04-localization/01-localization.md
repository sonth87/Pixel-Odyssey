# Ngôn ngữ (localization)

## 1. Phạm vi

| Ngôn ngữ | Mã | Trạng thái |
|---|---|---|
| Tiếng Việt | `vi` | Có từ M4 (ngôn ngữ nguồn khi viết nội dung) |
| Tiếng Anh | `en` | Có từ M4 (ngôn ngữ mặc định khi máy không phải tiếng Việt) |
| Khác | — | Sau phát hành; kiến trúc không cần đổi |

Ngôn ngữ mặc định lần đầu mở game: theo ngôn ngữ hệ thống; nếu không hỗ trợ → `en`.

## 2. Quy tắc

1. **Không có chuỗi hiển thị nào nằm trong code** (FR-LC-01). Code chỉ dùng key: `tr("ui.menu.play")`.
2. Key theo dạng `nhóm.phần.tên`, chữ thường, gạch dưới:
   - `ui.*` — giao diện chung (shared)
   - `hud.*` — trong lúc chạy
   - `result.*` — màn kết quả
   - `settings.*`
   - `tutorial.*`
   - Nội dung của pack: `<pack>.character.<id>.name`, `<pack>.character.<id>.passive_desc`, `<pack>.item.<id>.name`, `<pack>.island.<id>.name`, `<pack>.segment.<id>.name`, `<pack>.fruit.<id>.name`
3. Chuỗi có biến dùng tham số có tên: `"result.distance": "{meters} m"` → `tr("result.distance").format({"meters": d})`. Không ghép chuỗi bằng `+` (thứ tự từ khác nhau giữa các ngôn ngữ).
4. Số: định dạng theo ngôn ngữ (tiếng Việt `12.540`, tiếng Anh `12,540`) qua một hàm định dạng chung.
5. Chữ nội dung của pack nằm **trong** thư mục pack (FR-LC-03); đổi pack đổi luôn tên.
6. Tên riêng One Piece giữ nguyên tiếng Anh/Nhật ở cả hai ngôn ngữ (Gomu Gomu, Alabasta); phần mô tả thì dịch.

## 3. File

Godot hỗ trợ CSV và gettext (.po). **Chọn CSV** (`ĐỀ XUẤT`): dễ mở bằng bảng tính, một file chứa mọi ngôn ngữ cạnh nhau → khó bỏ sót bản dịch.

```
game/shared/localization/ui.csv
game/content/onepiece/localization/onepiece.csv
```
Định dạng:
```
keys,vi,en
ui.menu.play,Chơi,Play
ui.menu.settings,Cài đặt,Settings
result.new_record,KỶ LỤC MỚI!,NEW RECORD!
onepiece.character.luffy.passive_desc,Thời gian mọi năng lực +20%,All power-up durations +20%
```

Kiểm tra tự động (M4): mọi key có đủ cột cho mọi ngôn ngữ; mọi key dùng trong code/dữ liệu tồn tại trong CSV.

## 4. Font

Đây là phần dễ bị bỏ quên nhất với tiếng Việt.

**Yêu cầu** (FR-LC-02):
- Font pixel (đúng phong cách), hiển thị đủ toàn bộ chữ tiếng Việt, kể cả chữ **hai dấu chồng** (ấ, ầ, ẩ, ẫ, ậ, ắ, ằ, ẳ, ẵ, ặ, ế, ề, ể, ễ, ệ, ố, ồ, ổ, ỗ, ộ...) và chữ hoa có dấu (Ắ, Ệ, Ữ).
- Dấu không được dính vào dòng trên → **chiều cao dòng** phải chừa chỗ cho 2 tầng dấu phía trên chữ hoa và dấu nặng phía dưới.

**Ước lượng kích thước** (trên lưới UI 640×360 — D-017):
- Thân chữ hoa 7 px + 2 tầng dấu (mũ + sắc/huyền) ~4 px + dấu nặng dưới 2 px → dòng ≥ 13–14 px.
- Ở lưới thế giới 320×180 cùng font này sẽ chiếm ~8% chiều cao màn hình một dòng — quá to; đó là lý do UI dùng lưới 640×360.

**Cách chọn font (M4)**:
1. Tìm font pixel có giấy phép cho phép dùng trong game thương mại và hỗ trợ tiếng Việt; mở trang thử chữ:
   ```
   ẮẰẲẴẶ ẤẦẨẪẬ ẾỀỂỄỆ ỐỒỔỖỘ ỚỜỞỠỢ ỨỪỬỮỰ Đ đ
   Thời gian mọi năng lực tăng. Kỷ lục mới! Chơi lại
   ```
2. Không tìm được → **tự vẽ font bitmap** trong Pixelorama (chỉ cần ~200 ký tự: Latin + tiếng Việt + số + dấu câu), xuất định dạng BMFont (.fnt) mà Godot đọc được. Đây là phương án chắc chắn nhất và đồng bộ phong cách nhất.
3. Phương án dự phòng chắc chắn có đủ ký tự: GNU Unifont (lưới 16 px) — chỉ dùng tạm vì to và không đúng phong cách.

Ghi lựa chọn font + giấy phép vào decision log.

## 5. Độ dài chữ

- Tiếng Việt thường dài hơn tiếng Anh 10–30%. UI phải chừa chỗ: nút rộng theo chữ dài nhất; không cắt chữ.
- Chữ trong hình (sprite) như "PERFECT" — vẽ riêng bản `vi` nếu muốn dịch ("HOÀN HẢO"); đề xuất giữ "PERFECT" ở mọi ngôn ngữ vì là từ quen thuộc trong game (`ĐỀ XUẤT`).

## 6. Danh sách chuỗi khởi đầu (M4)

| Key | vi | en |
|---|---|---|
| `ui.menu.play` | Chơi | Play |
| `ui.menu.characters` | Nhân vật | Characters |
| `ui.menu.settings` | Cài đặt | Settings |
| `hud.distance` | {meters} m | {meters} m |
| `hud.combo` | x{mult} | x{mult} |
| `hud.paused` | Tạm dừng | Paused |
| `result.distance` | Quãng đường | Distance |
| `result.score` | Điểm | Score |
| `result.best` | Kỷ lục | Best |
| `result.new_record` | KỶ LỤC MỚI! | NEW RECORD! |
| `result.reached` | Đã tới | Reached |
| `result.new_island` | Đảo mới! | New island! |
| `result.retry` | Chơi lại | Retry |
| `result.menu` | Menu | Menu |
| `settings.music` | Nhạc | Music |
| `settings.sfx` | Hiệu ứng | Sound effects |
| `settings.language` | Ngôn ngữ | Language |
| `settings.vibration` | Rung | Vibration |
| `settings.screen_shake` | Rung màn hình | Screen shake |
| `settings.reduce_flashing` | Giảm nhấp nháy | Reduce flashing |
| `tutorial.tap` | Chạm để nhảy | Tap to jump |
| `tutorial.hold` | Giữ để nhảy cao | Hold to jump higher |
