# Điểm số, tiến trình, meta

## 1. Hai thước đo trong một run

| Thước đo | Cách tính | Phục vụ ai |
|---|---|---|
| **Quãng đường** (m) | `floor(px đã chạy ÷ 16)` tại tick chết | Người muốn "đi xa nhất" — thước đo chính, bảng xếp hạng chính (D-016) |
| **Điểm** | quãng đường + Σ điểm cố định + Σ (điểm kỹ năng × hệ số combo) | Người thích kỹ thuật (perfect, đạp, combo) |

Vì sao 16 px = 1 m: nhân vật cao 24 px ≈ 1.5 m; con số mét tăng đủ nhanh để thấy tiến bộ.

## 2. Sự kiện tính điểm

`ĐỀ XUẤT` — chỉnh sau khi có bot mô phỏng và playtest.

### 2.1 Định nghĩa "vượt qua"
- Một chướng ngại vật/kẻ địch/vật bay/mối nguy được tính **vượt qua** khi mép phải hitbox của nó đi qua mép trái hurtbox người chơi, người chơi còn sống và vật **chưa** bị phá/đạp.
- Một **hố** được tính vượt qua khi người chơi đáp đất ở phía sau mép phải của hố.
- Bậc địa hình không tính.
- Mỗi vật chỉ được tính **một lần**, cho đúng một sự kiện (vượt qua, perfect, đạp hoặc phá).

### 2.2 Bảng điểm
| Sự kiện | Điểm | Nhân combo? | Combo |
|---|---|---|---|
| Vượt qua (thường) | 0 | — | +1 |
| **Perfect** (mục 3) | 25 | Có | +2 |
| **Đạp** kẻ địch | 25 | Có | +2 |
| Phá vật bằng năng lực (biến hình, trái, nội tại, khiên) | 10 | Có | +1 |
| Nhặt item năng lực | 20 | Không | 0 |
| Nhặt xu | 0 (chỉ cho Berries) | — | 0 |
| Qua một đoạn | 100 | Không | 0 |
| Qua một đảo | 500 | Không | 0 |

**Vì sao vượt qua thường = 0 điểm, xu = 0 điểm**: số chướng ngại vật và số xu phụ thuộc chuỗi chunk ngẫu nhiên; nếu chúng cho điểm, điểm sẽ phụ thuộc may rủi về mật độ hơn là kỹ năng. Điểm chỉ đến từ hành động **có rủi ro** (perfect, đạp) và từ tiến độ hành trình.

Điểm kỹ năng nhân hệ số được **làm tròn xuống** ở từng sự kiện. `score_mult` (nếu có) nhân sau hệ số combo.

## 3. Perfect Jump — định nghĩa chính xác

Áp dụng cho vật mà người chơi **vượt qua phía trên** (hurtbox nằm hoàn toàn phía trên hitbox trong suốt khoảng chồng nhau theo chiều ngang):
```
clearance = min( đỉnh_hitbox − đáy_hurtbox )   trên mọi tick hai box chồng nhau theo chiều ngang   (px, > 0)
PERFECT nếu clearance ≤ perfect_threshold     (4 px; Usopp 6 px)
```
Với **hố**: PERFECT nếu điểm giậm nhảy cách mép trái hố ≤ 4 px (tính cả nhảy trong coyote time — nhảy từ "không trung" ngay sau mép).

**Không** tính Perfect khi đang i-frames, biến hình hoặc lao tốc (không có rủi ro thì không có thưởng). Có khiên vẫn tính (khiên không loại bỏ rủi ro mất khiên).

Vật bay chạy **bên dưới** không có Perfect.

Thực tế, Perfect đạt được bằng cách **nhảy muộn** (vừa kịp lên khi chạm mép trước của vật) hoặc **đáp sớm** (rơi sát mép sau) — cả hai đều mạo hiểm. Đó là chủ đích.

## 4. Combo

- Tăng theo bảng mục 2.2.
- **Về 0** khi: mất khiên vì va chạm.
- Hệ số: `combo_mult = 1 + 0.05 × min(combo, 40)` → tối đa **×3.0** ở combo 40.
- Hiển thị: "x1.7" cạnh điểm, phóng to nhẹ khi tăng mỗi 0.5.
- Vì sao không reset theo thời gian: runner không cho người chơi chủ động tạo hành động; reset theo thời gian sẽ phạt các đoạn nghỉ do game quyết định.

## 5. Ước lượng cân bằng

Giả định tốc độ trung bình ~13 m/s, khoảng 1 vật mỗi 1.2 s:

| Kiểu người chơi | Điểm từ quãng đường | Điểm kỹ năng ước tính | Tổng / phút |
|---|---|---|---|
| Mới (perfect 5%, không đạp) | ~780 | ~80 | ~860 |
| Trung bình (perfect 15%, đạp vài lần, combo ~×2) | ~780 | ~600 | ~1.400 |
| Giỏi (perfect 35%, đạp thường xuyên, combo ×3) | ~780 | ~2.000 | ~2.800 |

Kết luận: quãng đường vẫn là phần nền; kỹ năng có thể **gấp 2–3 lần** điểm — đủ để người giỏi khác biệt, không đủ để điểm hoàn toàn tách rời khỏi quãng đường. Các con số phải được xác nhận bằng bot mô phỏng.

## 6. Bảng xếp hạng

- Xếp theo quãng đường; **hoà** → điểm cao hơn; vẫn hoà → ai đạt trước.
- Bảng phụ xếp theo điểm.
- Chỉ run hợp lệ được ghi: không phải bản debug, không phải run hướng dẫn, (M7) có bản ghi input phát lại hợp lệ.

## 7. Kết thúc run — màn kết quả

Hiện theo thứ tự (mỗi dòng xuất hiện nối tiếp ~0.15 s, chạm để bỏ qua hiệu ứng):
1. Quãng đường (m) — to nhất. Nếu là kỷ lục: "KỶ LỤC MỚI!" + âm thanh.
2. Điểm, combo cao nhất, số Perfect.
3. Đảo đã tới (tên + biểu tượng) — nếu là đảo mới lần đầu: "Đảo mới!".
4. Berries kiếm được (từ M7).
5. Nút: **Chơi lại** (to, chiếm phần lớn), Menu, (M7: Bảng xếp hạng).

## 8. Tiến trình giữa các run

| Thứ được lưu | Mục đích | Có ảnh hưởng run sau? |
|---|---|---|
| Kỷ lục quãng đường, kỷ lục điểm | Mục tiêu cá nhân | Không |
| Đảo xa nhất từng tới | Cảm giác tiến bộ trên hành trình; hiện "bản đồ hành trình" ở menu | **Không** — không phải checkpoint (D-002) |
| Số lần chơi, tổng quãng đường, tổng Perfect, tổng đạp | Thống kê, thành tựu | Không |
| Berries, nâng cấp, nhân vật/skin đã mở (M7) | Giữ chân dài hạn | Có (nâng cấp) — xem Q-02 |

## 9. Meta (M7) — `ĐỀ XUẤT`

### 9.1 Berries
- Kiếm: xu nhặt trong run + thưởng theo quãng đường (1 Berry / 10 m) + thưởng đảo mới lần đầu.
- Tiêu: mở nhân vật, mở skin, nâng cấp.

### 9.2 Nâng cấp
Mỗi nâng cấp 5 cấp, giá tăng dần:
- Thời hạn item biến hình +0.5 s/cấp.
- Xác suất item +4%/cấp.
- Bắt đầu run với 1 khiên (chỉ 1 cấp, đắt).

**Không có** nâng cấp tăng tốc độ khởi đầu hay giảm độ khó — vì làm méo cân bằng thiết kế chunk.

Ảnh hưởng tới bảng xếp hạng: `MỞ` Q-02. Phương án mạnh nhất hiện tại: thử thách hằng ngày luôn **tắt nâng cấp**, bảng xếp hạng thường cho phép nâng cấp.

### 9.3 Mở khoá nhân vật
- Luffy: có sẵn.
- Nhân vật khác: mở bằng Berries **hoặc** khi lần đầu tới đảo gắn với nhân vật đó trong hành trình (khai báo trong dữ liệu nhân vật). Vì: gắn mở khoá với hành trình → lý do để đi xa hơn.

### 9.4 Thử thách hằng ngày
- Seed cố định theo ngày (UTC), mọi người cùng chuỗi chunk và item (đảm bảo bởi D-021).
- Nhân vật cố định theo ngày, nâng cấp tắt.
- Bảng xếp hạng riêng theo ngày.

### 9.5 Bóng ma kỷ lục (ý tưởng, chưa xếp milestone)
Vì run tất định theo seed + input, có thể phát lại run kỷ lục của chính mình (hoặc bạn bè, trong thử thách hằng ngày) dưới dạng nhân vật đổi sang bảng màu xám (không dùng bán trong suốt, giữ luật pixel art) chạy song song — một "đối thủ" thật sự trong game một người chơi. Chi phí thấp nếu đã có ghi/phát lại input.
