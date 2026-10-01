# Quy tắc code

Áp dụng cho mọi code trong `game/` và `tools/`, dù người viết hay AI viết.

## 1. Nguyên tắc

1. **Một việc cho mỗi file, mỗi hàm.** Nếu mô tả một class cần chữ "và" → tách.
2. **Không god file, không god function.**
   - File script: mục tiêu ≤ 200 dòng, **trần 300 dòng**. Vượt → tách trước khi thêm.
   - Hàm: mục tiêu ≤ 30 dòng, **trần 50 dòng**; ≤ 4 tham số (nhiều hơn → gom vào Resource/struct).
   - Độ lồng ≤ 3 cấp; dùng return sớm.
3. **Không code thừa.** Không viết trước cho nhu cầu giả định. Không để code chết, code comment bỏ đi, hàm không ai gọi, tham số không dùng. Xoá luôn — git còn giữ.
4. **Không trùng lặp có ý nghĩa.** Logic giống nhau ở 2 nơi → cân nhắc; ở 3 nơi → gom. Nhưng không trừu tượng hoá chỉ vì hai đoạn trông giống nhau.
5. **Dữ liệu thay vì nhánh `if`.** Không viết `if item_id == "meat"`. Hành vi khác nhau theo nội dung phải đến từ dữ liệu (Resource) hoặc đa hình (lớp con hiệu ứng).
6. **Ghép (composition) hơn kế thừa.** Kế thừa class tự viết tối đa 2 tầng. Node con đảm nhận từng phần.
7. **"Signal đi lên, gọi hàm đi xuống".** Node cha gọi hàm node con; node con báo lên bằng signal. Không `get_parent().get_parent()`. Không đường dẫn node tuyệt đối dài; dùng `@export` hoặc unique name (`%Name`).
8. **Không số ma thuật.** Thông số chỉnh được nằm trong Resource cấu hình hoặc hằng số có tên ở đầu file; thông số vật lý chỉ định nghĩa một nơi (`runner/physics/`).
9. **Không trạng thái toàn cục** ngoài các autoload đã duyệt ([architecture](01-architecture.md#3-autoload-toàn-cục)). Không biến `static var` làm nơi chứa trạng thái game.
10. **Trung lập với IP** trong `shared/` và `runner/` (kiểm tra bằng `tools/check_ip_names.py`).
11. **Tôn trọng chiều phụ thuộc giữa các lớp** (kiểm tra bằng `tools/check_layers.py`).

## 2. GDScript

- **Khai báo kiểu tĩnh bắt buộc** cho biến, tham số, giá trị trả về: `func apply(effect: EffectData) -> void:`. Bật cảnh báo *untyped declaration* thành lỗi trong project settings.
- Theo thứ tự trong file (theo hướng dẫn chính thức của Godot): `class_name` → `extends` → signal → enum → const → `@export` → biến công khai → biến riêng (`_ten`) → `@onready` → hàm có sẵn (`_ready`, `_physics_process`) → hàm công khai → hàm riêng.
- Biến/hàm riêng có tiền tố `_`.
- Enum thay cho chuỗi khi tập giá trị cố định trong code; `StringName` (`&"jump_rise"`) cho ID/tên animation.
- Không dùng `randi()`/`randf()` toàn cục trong `runner/` — dùng `RunContext.rng.<luồng>`.
- Logic gameplay chỉ trong `_physics_process`; `_process` chỉ cho hình ảnh.
- Mô phỏng gameplay (vị trí, vận tốc, va chạm, quãng đường) dùng **số nguyên cố định**, không dùng `float` (D-027). Chuyển sang `float` chỉ ở lớp hiển thị.
- Không `await` trong logic gameplay theo tick (gây khó tất định); dùng bộ đếm tick.
- Không giữ tham chiếu tới node đã trả về pool.

## 3. Comment

Quy tắc theo D-015: code đang ở giai đoạn đầu, mọi thứ thay đổi liên tục; comment phải **đúng tại thời điểm hiện tại**.

**Được viết:**
- Lý do không hiển nhiên: ràng buộc ẩn, công thức, lý do chọn con số.
  ```gdscript
  # Gravity is reduced while holding so the max height is reachable within MAX_HOLD_TIME.
  ```
- Cảnh báo về hành vi gây ngạc nhiên.
- Doc comment `##` một dòng cho API công khai của `shared/` khi tên chưa nói đủ.

**Không được viết:**
- Lịch sử thay đổi: ~~`# đổi từ 300 sang 260 theo yêu cầu`~~, ~~`# trước đây dùng X`~~, ~~`# sửa lại vì người dùng bảo`~~, ~~`# chuyển về tính năng cũ`~~.
- Nhắc tới task/người/cuộc trò chuyện: ~~`# thêm cho M2`~~, ~~`# theo feedback`~~.
- Diễn giải lại code: ~~`# tăng combo lên 1`~~ phía trên `combo += 1`.
- Code bị comment để "giữ lại phòng khi cần".
- Khối comment nhiều đoạn, docstring dài.

**TODO**: chỉ khi thật cần, dạng `# TODO(M4): <việc>` và phải dọn trước khi đóng milestone đó.

Lịch sử và lý do thay đổi thuộc về **commit message** và **decision log**.

## 4. Scene và Resource

- Scene nhỏ, dùng lại được; scene gốc của một hệ thống không chứa logic hệ thống khác.
- Resource (`.tres`) là dữ liệu thuần, **không chứa logic gameplay**. Hàm trong class Resource chỉ được tính toán từ chính dữ liệu của nó (ví dụ `total_percent()`).
- Mọi `@export` trong Resource có kiểu và giá trị mặc định hợp lý; dùng `@export_range` cho số có giới hạn.
- Không sửa Resource dùng chung lúc chạy (Resource được chia sẻ giữa các instance) — cần trạng thái thì tạo object riêng.

## 5. Xử lý lỗi

- **Kiểm tra kỹ ở ranh giới**: nạp content pack, đọc file save, dữ liệu người dùng. Lỗi phải có thông báo rõ (pack nào, file nào, thiếu gì).
- **Bên trong**: tin tưởng dữ liệu đã kiểm tra; dùng `assert()` cho bất biến (chỉ chạy ở bản debug), không viết nhánh xử lý cho tình huống không thể xảy ra.
- Không nuốt lỗi im lặng.

## 6. Test

Dùng **gdUnit4**. Bắt buộc có test cho:

| Phần | Vì sao |
|---|---|
| Công thức vật lý nhảy (độ cao, thời gian bay) | Validator và game dựa vào nó |
| `RngStreams` tất định | NFR-DT-01 |
| Validator chunk (chunk hợp lệ / không hợp lệ mẫu) | FR-WD-04 |
| Quy tắc chồng hiệu ứng | FR-IT-05 |
| Điểm, combo | FR-SC-02 |
| Nâng cấp file save | NFR-SV-01 |
| Đủ key ngôn ngữ | FR-LC-01 |
| Bộ animation nhân vật đủ trạng thái bắt buộc | FR-CH-02 |

Test đặt tên theo hành vi: `test_hold_jump_reaches_max_height_after_max_hold_time`.

## 7. Git

- Commit nhỏ, một ý. Message dạng: `feat: ...`, `fix: ...`, `refactor: ...`, `docs: ...`, `art: ...`, `audio: ...`, `test: ...`, `chore: ...`. Dòng đầu ≤ 72 ký tự, nói **vì sao** nếu không hiển nhiên.
- Nhánh: `main` luôn chạy được; làm việc trên nhánh `ms<N>/<việc>` rồi gộp.
- File nhị phân (png, ogg, wav, aseprite) qua **Git LFS**.
- Không commit: thư mục `.godot/`, bản build, file tạm.

## 8. Checklist trước khi coi một thay đổi là xong

- [ ] Chạy được, không có cảnh báo mới trong Godot.
- [ ] Test liên quan có và pass.
- [ ] Không file nào vượt 300 dòng, không hàm nào vượt 50 dòng.
- [ ] Không comment lịch sử, không code chết.
- [ ] `check_layers.py`, `check_ip_names.py` pass.
- [ ] Tài liệu liên quan đã cập nhật (nếu thay đổi hành vi/thông số/quy tắc) + decision log nếu là quyết định.
