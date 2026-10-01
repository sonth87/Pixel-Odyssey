# Trải nghiệm người chơi

## 1. Người chơi mục tiêu

| Nhóm | Mô tả | Họ cần | Thiết kế đáp ứng |
|---|---|---|---|
| Người chơi giết thời gian | Chơi lúc chờ, 1–5 phút, một tay | Vào chơi ngay, không đọc hướng dẫn | Một nút, hướng dẫn lồng trong run, thử lại tức thì |
| Fan One Piece | Biết nhân vật, đảo, sự kiện | Nhận ra chi tiết quen thuộc | Đảo theo thứ tự truyện, sự kiện boss ở nền, biến hình đặc trưng |
| Người săn điểm | Chơi lại hàng chục lần để phá kỷ lục | Công bằng, có trần kỹ năng | Không chết oan (validator), Perfect Jump, combo, bảng xếp hạng, thử thách hằng ngày |
| Người thích sưu tầm | Mở khoá đủ nhân vật, skin | Mục tiêu dài hạn | Mở nhân vật khi tới đảo họ gia nhập, Berries |

## 2. Thiết bị và tư thế cầm

- Điện thoại, màn hình **ngang**, cầm hai tay hoặc một tay. Chạm bất kỳ đâu → không phụ thuộc tay thuận.
- Nút pause ở **góc trên phải**, vùng chạm 48×48 (lưới UI) — đủ xa vùng chạm nhảy tự nhiên (nửa dưới màn hình).
- Vùng "an toàn" (tai thỏ, góc bo): UI không đặt trong vùng an toàn hệ thống báo về.
- PC: Space / ↑ / chuột trái; Esc = pause.

## 3. Luồng màn hình

```
[Khởi động] ─► [Menu chính] ─► (lần đầu: vào thẳng run hướng dẫn)
                  │  ├─ Chơi ───────────────► [Run] ─► chết ─► [Kết quả] ─┬─ Chơi lại ─► [Run]
                  │  ├─ Nhân vật (M5) ──► [Chọn nhân vật]                 └─ Menu ─────► [Menu chính]
                  │  ├─ Hành trình ────► [Bản đồ hành trình] (đảo đã tới)
                  │  ├─ Cài đặt ───────► [Cài đặt]
                  │  └─ (M7) Cửa hàng, Bảng xếp hạng, Thử thách hằng ngày
                  │
[Run] ─ pause ─► [Pause: Tiếp tục / Chơi lại / Cài đặt / Menu]
```

### Khởi động
Logo ngắn (≤ 1.5 s, chạm để bỏ qua) → menu. Lần đầu tiên mở game: vào thẳng run hướng dẫn (không qua menu) — người chơi đang chạy trong ≤ 5 giây.

### Menu chính
- Nền: cảnh đảo gần nhất người chơi từng tới, parallax trôi chậm; nhân vật đang chọn `idle`/`sit_idle`.
- Nút **Chơi** to nhất, giữa-dưới.
- Kỷ lục hiện nhỏ ở góc.

### Trong run (HUD)
- Trên trái: quãng đường (to), điểm + hệ số combo (nhỏ).
- Trên phải: pause.
- Dưới trái (hoặc dưới nhân vật): ô năng lực đang có với vòng thời gian.
- Khi vào đảo/đoạn mới: tên đảo hiện mờ dần ở giữa-trên trong 1.5 s (không che vùng chơi).
- HUD không chiếm vùng y 90–148 (vùng chướng ngại vật).

### Kết quả
Xem [scoring](../01-game-design/05-scoring-progression-meta.md#7-kết-thúc-run--màn-kết-quả). Nút **Chơi lại** to, nhận chạm sau 0.4 s (tránh bấm nhầm do đang nhảy).

### Cài đặt
| Cài đặt | Giá trị | Tác dụng | Mặc định |
|---|---|---|---|
| Nhạc | 0–100% | Bus Music + Ambience | 80% |
| Hiệu ứng | 0–100% | Bus SFX + UI | 100% |
| Ngôn ngữ | Tiếng Việt / English | Đổi toàn bộ chữ ngay lập tức | Theo máy |
| Rung | Bật/Tắt | Haptics | Bật |
| Rung màn hình | Bật/Tắt | CameraRig shake | Bật |
| Giảm nhấp nháy | Bật/Tắt | Chớp sáng → đổi tông màu nhẹ; hit-flash trắng → không | Tắt |
| (dev) Content pack | danh sách | Đổi chủ đề | onepiece |

Mọi cài đặt có tác dụng **ngay**, lưu ngay.

## 4. Hướng dẫn chơi (lần đầu)

Lồng trong run đầu tiên, không có trang chữ:
1. 3 s chạy trống → bàn tay nhấp nháy + chữ "Chạm để nhảy" trước vật thấp đầu tiên. **Game chậm lại 50%** khi vật tới gần nếu người chơi chưa chạm (chỉ lần đầu).
2. Vật cao đầu tiên → "Giữ để nhảy cao".
3. Sau khi vượt vật cao → hướng dẫn biến mất vĩnh viễn (lưu cờ).
4. Nếu chết trong hướng dẫn → chơi lại vẫn còn hướng dẫn cho tới khi vượt được bước 2.

## 5. Gián đoạn và lưu

- App xuống nền / có cuộc gọi → pause ngay; quay lại thấy màn pause và đếm 3-2-1 khi bấm tiếp tục.
- Mất kết nối mạng → không ảnh hưởng chơi (NFR-OF-01).
- Lưu sau mỗi run và mỗi lần đổi cài đặt; ghi an toàn.

## 6. Accessibility

| Vấn đề | Giải pháp |
|---|---|
| Nhạy cảm ánh sáng nhấp nháy | Tuỳ chọn giảm nhấp nháy; sự kiện sét/chớp không nhấp nháy quá 3 lần/giây kể cả khi tắt tuỳ chọn |
| Mù màu | Loại chướng ngại vật phân biệt bằng hình dáng; item quý có hình dáng riêng |
| Say chuyển động | Tắt rung màn hình; camera dọc mượt |
| Khó nghe | Mọi tín hiệu âm thanh quan trọng (cảnh báo vật rơi) đều có tín hiệu hình (dấu "!", bóng đổ) |
| Phản xạ chậm | (cân nhắc sau M4) chế độ thư giãn tốc độ thấp hơn, không tính bảng xếp hạng |

## 7. Cảm giác cần đạt — kiểm tra khi playtest

- [ ] Người mới hiểu cách chơi trong 10 giây mà không ai giải thích.
- [ ] Khi chết, người chơi nói "à mình nhảy sớm" chứ không phải "cái gì vậy?".
- [ ] Người chơi tự bấm chơi lại.
- [ ] Người chơi nhắc tới một chi tiết nền (ví dụ "thấy Crocodile ở trên kìa").
- [ ] Không ai phàn nàn "bấm mà không nhảy".
