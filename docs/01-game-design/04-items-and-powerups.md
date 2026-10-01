# Item và năng lực

## 1. Nguyên tắc

- Item = **tổ hợp hiệu ứng nguyên tố** + **kiểu thời hạn** + **hình ảnh/âm thanh**. Không có code riêng cho từng item (FR-IT-02).
- Code không biết "thịt" hay "bong bóng"; nó biết `transform_item`, `shield_item`.
- Content pack quyết định item trông thế nào và tên gì.
- Mọi hiệu ứng phải tuân thủ **bất biến hiệu ứng** (mục 5): một hiệu ứng chỉ được làm người chơi **an toàn hơn hoặc bằng** trạng thái thường. Vì: chunk chỉ được kiểm định ở trạng thái thường; hiệu ứng làm thay đổi quỹ đạo/kích thước/tốc độ mà không kèm bảo vệ có thể tạo ra tình huống không thể vượt qua.

Cách item tương tác với từng loại vật: [luật tương tác](09-interaction-rules.md).

## 2. Kiểu thời hạn

| Kiểu | Code | Ý nghĩa | Ví dụ |
|---|---|---|---|
| Tức thì | `instant` | Tác dụng một lần rồi hết | Xu Berry (+tiền, +điểm) |
| Theo thời gian | `timed` | Kéo dài N giây | Biến hình 8 s, trái Pika 4 s |
| Theo số lần | `charges` | Hết khi dùng hết N lần | Khiên bong bóng: chặn 1 va chạm |

## 3. Hiệu ứng nguyên tố

Danh sách khởi đầu (`ĐỀ XUẤT`). Thêm hiệu ứng mới = thay đổi code, phải cập nhật bảng này và kiểm tra bất biến.

| Hiệu ứng | Tham số | Tác dụng |
|---|---|---|
| `shield` | charges | Chặn `CONTACT`; mỗi lần trừ 1; vỡ → i-frames |
| `invincible` | — | Bỏ qua `CONTACT` (không phá vật). Không bảo vệ khỏi `PIT`, `WALL` |
| `destroy_on_contact` | filter | `CONTACT` với vật trong bộ lọc → vật bị phá (vật không phá được thì đi xuyên) |
| `rush` | — | Bảo vệ toàn phần: phá/xuyên mọi vật, tự bắc cầu qua hố, tự leo bậc |
| `speed_mult` | hệ số ≥ 1 | Nhân tốc độ chạy |
| `size_mult` | hệ số ≥ 1 | Phóng to hình + hurtbox |
| `jump_mult` | hệ số ≥ 1 | Nhân vận tốc nhảy |
| `extra_jumps` | số lần, hệ số độ cao | Nhảy thêm trên không |
| `phase_through` | filter | Đi xuyên vật trong bộ lọc |
| `bridge_gaps` | — | Hố trở thành mặt đất |
| `magnet` | bán kính | Hút xu về phía nhân vật |
| `score_mult` | hệ số | Nhân điểm sự kiện |
| `auto_destroy` | cooldown, filter, tầm | Tự phá vật phía trước định kỳ |
| `duration_mult` | hệ số | Kéo dài mọi hiệu ứng timed (nội tại Luffy) |
| `item_spawn_mult`, `coin_mult`, `perfect_window_mult`, `combo_gain_mult`, `start_shield`, `preview_hazards` | hệ số / số | Hiệu ứng nội tại (luôn bật) |

Nội tại nhân vật dùng **cùng hệ thống** này với thời hạn "vĩnh viễn trong run".

## 4. Danh sách item (content pack One Piece)

| Item (One Piece) | Loại trung lập | Thời hạn | Hiệu ứng | Ghi chú | MS |
|---|---|---|---|---|---|
| Xu Berry | `coin` | instant | +1 Berry | Xếp thành hàng gợi ý đường nhảy | M2 |
| Túi Berry | `coin_bag` | instant | +10 Berry | Hay đặt ở chỗ mạo hiểm | M2 |
| Bong bóng Sabaody | `shield_item` | charges 1 | `shield 1` | Bong bóng bao quanh nhân vật | M2 |
| Thịt có xương | `transform_item` | timed 6–8 s | Theo dạng biến hình của nhân vật (luôn kèm bảo vệ E2) | Mỗi nhân vật khác nhau | M2 |
| Log Pose | `magnet_item` | timed 8 s | `magnet` | | M6 |
| Cola (Franky) | `speed_item` | timed 4 s | `speed_mult 1.3` + `rush` | Phản lực sau lưng | M6 |

### Trái ác quỷ

Ăn trái → ngẫu nhiên một trái trong pool (trọng số), hiển thị tên trái ngắn gọn trên màn hình.

| Trái | Hiệu ứng | Thời hạn | Cảm giác |
|---|---|---|---|
| Gomu Gomu | `jump_mult 1.3` + `destroy_on_contact (air, falling, projectile)` | 8 s | Nhảy cao, đấm bay mọi thứ trên không |
| Mera Mera | `destroy_on_contact (enemy_*)`, vệt lửa | 7 s | Đốt kẻ địch |
| Hie Hie | `bridge_gaps` (hố đóng băng thành mặt đất) | 8 s | Hố không còn đáng sợ |
| Pika Pika | `speed_mult 1.5` + `rush`, vệt sáng | 4 s | Lao vun vút, cộng quãng đường nhanh |
| Nikyu Nikyu | `auto_destroy` cooldown 1.2 s, mọi loại phá được | 6 s | Dọn đường |
| Bari Bari | `shield 3` | đến khi hết | Rào chắn ba lớp |

## 5. Bất biến của hiệu ứng

`ContentRegistry` kiểm tra mọi item, nội tại, dạng biến hình khi nạp pack; vi phạm → lỗi nạp (D-020).

| Mã | Bất biến | Vì sao |
|---|---|---|
| **E1** | Hiệu ứng có `speed_mult > 1` phải kèm `rush` | Nhanh hơn tốc độ đã kiểm định → hố/vật có thể không còn kịp phản ứng (ở 450 px/s chỉ còn ~0.57 s nhìn trước) |
| **E2** | Mọi dạng biến hình, và mọi hiệu ứng có `size_mult > 1`, phải kèm `destroy_on_contact (mọi loại)` | Hurtbox to hơn không chui lọt dưới vật bay dải thấp (hurtbox 30 px > khe 22–28 px) |
| **E3** | Hiệu ứng có `jump_mult > 1` phải kèm `destroy_on_contact (air, falling, projectile)` | Nhảy chạm cao hơn sẽ đâm vào vật bay dải cao trong các chunk thiết kế "chỉ được nhảy thấp" |
| **E4** | Không hiệu ứng nào được có `speed_mult < 1`, `jump_mult < 1`, `size_mult < 1` hoặc làm hurtbox to hơn mà không theo E2 | Chậm hơn/nhảy thấp hơn làm hố và vật cao không còn vượt qua được |

`extra_jumps` không cần bảo vệ vì chỉ **thêm** lựa chọn (người chơi vẫn có thể không dùng).

Khi kết thúc hiệu ứng có E1/E2: luôn có thời gian bảo vệ chuyển tiếp ([physics §5](../05-technical/05-physics-collision-generation.md#5-hitbox-hurtbox-dung-sai)).

## 6. Quy tắc chồng hiệu ứng (FR-IT-05)

1. **Cùng item timed ăn lại** khi đang có → **cộng dồn thời gian** tới tối đa 1.5× thời hạn gốc.
2. **Biến hình mới khi đang biến hình** → làm mới thời gian (không chồng hai dạng).
3. **Trái ác quỷ mới khi đang có trái** → thay trái cũ (mỗi lúc chỉ một trái). Vì: tránh tổ hợp mạnh vô lý và tránh phải vẽ hình tổ hợp.
4. **Khiên** cộng dồn số lần, tối đa 3.
5. Hiệu ứng `*_mult` cùng loại từ nhiều nguồn **nhân** với nhau rồi **kẹp**: `speed_mult` ≤ 1.5, `jump_mult` ≤ 1.4, `size_mult` ≤ 2.0. Vì: vật lý và hình ảnh chỉ được thiết kế trong khoảng này.
6. Biến hình + trái ác quỷ: được phép đồng thời (hai nhóm khác nhau).
7. Thứ tự ưu tiên khi xử lý va chạm: [luật tương tác §3](09-interaction-rules.md#3-thứ-tự-xử-lý-mỗi-tick).

## 7. Sinh item

### 7.1 Điểm đặt item trong chunk
Mỗi chunk có 0–4 **điểm đặt item** do người thiết kế đặt, mỗi điểm có:
- Nhãn `safe` (lấy được bằng nhảy bình thường) hoặc `risky` (phải mạo hiểm: nhảy cao sát vật trên không, nhảy sát mép hố...).
- Danh sách loại item cho phép.

Xu Berry được đặt theo **hàng** do chunk định nghĩa (gợi ý đường nhảy đẹp).

### 7.2 Quy tắc sinh (luồng RNG item)
- Item được quyết định **lúc dựng chunk** (trước khi người chơi tới), không lúc người chơi tới gần.
- Mỗi điểm đặt có xác suất có item theo cấu hình đoạn (ví dụ 35%).
- Item quý (`transform_item`, `devil_fruit`, `speed_item`) chỉ ở điểm `risky` (ngoại trừ đảo hướng dẫn).
- **Giới hạn** (tính theo số đã **sinh**, không theo số đã nhặt — để chuỗi sinh không phụ thuộc người chơi): mỗi đảo tối đa N trái ác quỷ (đề xuất 2), mỗi đoạn tối đa 1; tối đa M item biến hình mỗi đảo (đề xuất 2).
- Khoảng cách tối thiểu giữa hai item quý: 400 m.
- Nội tại Nami (`item_spawn_mult`) nhân xác suất, không vượt giới hạn.
- **Không có cơ chế bù may rủi** mặc định (D-005). Tham số tuỳ chọn `luck_guard` để sẵn trong dữ liệu, mặc định tắt.

## 8. Phản hồi khi ăn item

| Item | Hình | Âm thanh | Chữ |
|---|---|---|---|
| Xu | Lấp lánh nhỏ | "ting" ngắn | — |
| Khiên | Bong bóng bao quanh | "bloop" | — |
| Biến hình | Hit-stop 3 frame + chớp trắng nhẹ + animation biến hình | Jingle ngắn riêng nhân vật | Tên dạng biến hình |
| Trái ác quỷ | Xoáy màu theo trái | Jingle trái ác quỷ | Tên trái |

Thanh thời hạn còn lại hiện ở HUD dưới dạng biểu tượng + vòng đếm.
