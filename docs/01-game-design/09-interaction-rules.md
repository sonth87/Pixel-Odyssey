# Luật tương tác

File này trả lời câu hỏi: **khi nhân vật chạm vào một thứ gì đó, chuyện gì xảy ra?** Đây là "luật chơi" chính thức; code của `CollisionResolver` phải làm đúng từng dòng ở đây và có test cho mỗi ô của ma trận.

Thông số (px, giây) ở [physics](../05-technical/05-physics-collision-generation.md). Hành vi từng thực thể ở [obstacles/enemies/NPC](08-obstacles-enemies-npc.md).

## 1. Nguồn gây chết

| Nguồn | Mã | Mô tả | Khiên đỡ được? |
|---|---|---|---|
| Va chạm | `CONTACT` | Hurtbox chạm hitbox của chướng ngại vật, kẻ địch, đạn, mối nguy | **Có** |
| Rơi hố | `PIT` | Đáy hurtbox xuống dưới vạch chết (dưới mép màn hình) — hố, biển | Không |
| Đâm tường | `WALL` | Mặt trước hurtbox đâm vào cạnh địa hình cao hơn ngưỡng tự leo (corner correction) | Không |

Vì sao khiên không đỡ hố và tường: khiên đỡ "bị đánh", không cứu được việc nhảy sai vị trí — giữ ý nghĩa của kỹ năng canh nhảy. Ngoại lệ duy nhất: trạng thái **lao tốc** (mục 3) bảo vệ khỏi cả hố và tường.

## 2. Các trạng thái bảo vệ của người chơi

| Trạng thái | Nguồn | Bảo vệ khỏi |
|---|---|---|
| **Thường** | — | Không gì |
| **Khiên** | Item khiên, nội tại | `CONTACT` (mỗi lần trừ 1 khiên) |
| **Bất tử ngắn (i-frames)** | Sau khi vỡ khiên (0.6 s), sau khi hết biến hình (0.5 s), lúc biến hình vào/ra | `CONTACT` |
| **Phá khi chạm** | Hiệu ứng `destroy_on_contact` theo bộ lọc | `CONTACT` với loại nằm trong bộ lọc (vật bị phá) |
| **Biến hình** | Item biến hình | `CONTACT` với **mọi** loại (phá vật được, đi xuyên mối nguy) — bất biến E2 ở [items](04-items-and-powerups.md#5-bất-biến-của-hiệu-ứng) |
| **Lao tốc** | Hiệu ứng tăng tốc (Pika, Cola) | `CONTACT`, `PIT` (tự bắc cầu qua hố), `WALL` (tự leo bậc) — bất biến E1 |
| **Xuyên** | `phase_through` theo bộ lọc | `CONTACT` với loại trong bộ lọc (vật không bị phá) |
| **Bắc cầu** | `bridge_gaps` | `PIT` |

## 3. Thứ tự xử lý mỗi tick

Mỗi tick, sau khi di chuyển người chơi và mọi vật:

1. **Rơi khỏi màn hình** → nếu không có bắc cầu/lao tốc: chết `PIT`. (Với bắc cầu/lao tốc: hố trở thành mặt đất trước khi rơi — người chơi không bao giờ rơi xuống.)
2. **Địa hình**: đáp đất, leo bậc (corner correction), hoặc `WALL`.
3. **Va chạm với vật**, xử lý lần lượt theo vị trí từ gần tới xa (x tăng dần). Với mỗi vật đang chạm:
   1. Đang **lao tốc** hoặc **biến hình** → vật bị phá (nếu `destructible`) hoặc đi xuyên (mối nguy, đạn không phá được) → **bỏ qua** các bước sau.
   2. Vật thuộc bộ lọc **phá khi chạm** → phá.
   3. Vật thuộc bộ lọc **xuyên** → bỏ qua.
   4. Đang **i-frames** → bỏ qua.
   5. **Đạp** hợp lệ (mục 5) → kẻ địch bị đạp, người chơi nảy lên.
   6. Có **khiên** → trừ 1 khiên, vật bị phá (nếu `destructible`, không thì giữ nguyên), bật i-frames 0.6 s.
   7. Còn lại → **chết `CONTACT`**.
4. Nhặt item (vùng nhặt rộng hơn hurtbox).
5. Ghi nhận sự kiện điểm (vượt qua, perfect...).

Trong một tick tối đa **một** khiên bị trừ — sau bước 3.6 các vật còn lại trong tick đó được i-frames che. Vì: hai vật chồng nhau không được "ăn" hai khiên một lúc.

## 4. Ma trận tương tác

Ký hiệu: **D** chết · **S** mất 1 khiên + vật bị phá · **S\*** mất 1 khiên, vật **không** bị phá (đi xuyên) · **X** vật bị phá (+điểm) · **B** đạp: vật bị hạ + nảy · **I** bỏ qua · **R** tự bắc cầu/tự leo · — không áp dụng.

| Loại vật | Thường | Khiên | i-frames | Đạp (đang rơi, từ trên) | Biến hình | Lao tốc |
|---|---|---|---|---|---|---|
| `ground_low` (thùng, xương rồng) | D | S | I | D (vật không đạp được) | X | X |
| `ground_tall` | D | S | I | D | X | X |
| `ground_wide` | D | S | I | D | X | X |
| `enemy_*` đạp được | D | S | I | **B** | X | X |
| `enemy_*` không đạp được (cá sấu, banana wani) | D | S | I | D | X | X |
| `air` (kền kền: đạp được) | D | S | I | B | X | X |
| Đạn (`projectile`) | D | S | I | D | X | X |
| `falling` (đang rơi) | D | S | I | D | X | X |
| `falling` sau khi nằm lại (`REMAIN_LOW`) | như `ground_low` | | | | | |
| `hazard` (cát xoáy, lưỡi cát) | D | S\* | I | D | I | I |
| Hố (`PIT`) | D | D | D | — | D | **R** |
| Tường (`WALL`) | D | D | D | — | D | **R** |

Ghi chú:
- `destroy_on_contact` / `phase_through` theo bộ lọc: các loại trong bộ lọc dùng cột "Biến hình" (phá) hoặc "I" (xuyên); loại ngoài bộ lọc dùng cột còn lại tương ứng.
- Nhân vật có `bridge_gaps` (Hie Hie): hàng Hố → **R**.

## 5. Đạp (stomp)

**Điều kiện** (tất cả đúng):
1. Người chơi **đang rơi** (vận tốc dọc hướng xuống).
2. Ở tick trước, đáy hurtbox ở **trên** đỉnh hitbox của vật (cho phép lún tối đa 4 px vào trong).
3. Vật có `stompable = true`.

**Kết quả**:
- Vật chuyển sang `stomped` (bẹp), không còn nguy hiểm.
- Người chơi nảy lên với vận tốc nảy cố định; **giữ nút** trong lúc nảy sẽ nảy cao hơn (dùng cùng cơ chế giữ của cú nhảy). Lượt nhảy thêm (nhảy đôi) được hồi lại.
- Điểm và combo: [scoring](05-scoring-progression-meta.md).

**Vì sao có đạp** (D-022): cho người chơi một cách tương tác chủ động với kẻ địch mà vẫn chỉ một nút; tạo lựa chọn mạo hiểm (đạp để lấy điểm) bên cạnh lựa chọn an toàn (nhảy qua). Validator **không** cần đạp để chứng minh chunk vượt qua được — đạp chỉ là lựa chọn thêm.

## 6. Mặt trên của chướng ngại vật

- Mọi `ground_*` **nguy hiểm ở mọi mặt**, kể cả mặt trên — không đứng lên được. Vì: đọc tình huống đơn giản ("vật = tránh"), và tách rõ với **địa hình** (bậc, mái nhà) là thứ đứng lên được.
- Muốn có vật đứng lên được (ví dụ thùng hàng làm bậc) → vẽ và đặt nó như **địa hình** (`terrain_step`), có hình dáng khác biệt rõ (bề mặt phẳng, viền sáng trên đỉnh).

## 7. Địa hình

| Tình huống | Luật |
|---|---|
| Đáp đất | Đáp được nếu đáy hurtbox chồng lên mặt đất ≥ 2 px theo chiều ngang (dung sai mép) |
| Chạy vào bậc cao ≤ 4 px | Tự bước lên, không cần nhảy |
| Bay vào cạnh bậc, đáy hurtbox thấp hơn đỉnh bậc ≤ 6 px | **Corner correction**: đẩy lên đứng trên bậc |
| Bay/chạy vào cạnh bậc, thấp hơn đỉnh > 6 px | `WALL` → chết |
| Chạy khỏi mép | Coyote time vẫn cho nhảy |
| Trần (mái che phía trên) | Không dùng trong game 1 — chunk không có trần |

Vì sao corner correction: mắt người chơi thấy "đã lên tới bậc rồi" khi chân còn thiếu vài pixel; chết lúc đó cảm giác oan. Đây là kỹ thuật chuẩn trong game platform.

## 8. Item

- Nhặt khi vùng nhặt (hurtbox nở 4 px) chạm item; mọi trạng thái đều nhặt được (kể cả biến hình, lao tốc).
- Item không bao giờ được đặt chồng lên hitbox nguy hiểm (validator kiểm tra).
- Nam châm hút xu và item `coin_*`; không hút item năng lực (để giữ quyết định mạo hiểm).
- Item trôi ra khỏi mép trái mà chưa nhặt → mất.

## 9. Kết thúc run, tạm dừng, thoát

| Tình huống | Luật |
|---|---|
| Chết | Quãng đường và điểm **đóng băng tại tick chết**; animation chết; màn kết quả |
| Tạm dừng | Được phép bất cứ lúc nào trừ trong animation chết. Khi tiếp tục: đếm 3-2-1, input trong lúc đếm bị bỏ qua, trạng thái "đang giữ nút" được xoá |
| App chạy nền | Tự tạm dừng |
| Thoát về menu giữa run | Run kết thúc **như khi chết** — kết quả được ghi nhận bình thường |
| App bị tắt hẳn giữa run | Run bị huỷ, không ghi kết quả, không tính là một lượt chơi |
| Run hướng dẫn (lần đầu) | Không ghi vào bảng xếp hạng (có làm chậm thời gian) |

## 10. Test bắt buộc

Mỗi ô của ma trận mục 4 là một test case (`test_<loại>_<trạng thái>_<kết quả>`), cộng:
- Hai vật trong một tick khi có 1 khiên → chỉ mất 1 khiên, không chết.
- Đạp: rơi từ trên → B; chạm từ bên cạnh khi đang rơi → D.
- Corner correction: thiếu 6 px → lên bậc; thiếu 7 px → `WALL`.
- Lao tốc qua hố rộng hơn tầm nhảy → sống.
- Biến hình hết giữa lúc đang chồng lên vật → i-frames, không chết.
