# Độ khó và nhịp chơi

Đây là phần quyết định game "cuốn" hay chỉ là một demo đẹp. Mọi con số ở đây là **điểm khởi đầu để test**, không phải chân lý.

## 1. Ba nguồn độ khó

| Nguồn | Điều khiển bởi | Ghi chú |
|---|---|---|
| Tốc độ chạy | Đường cong tốc độ theo quãng đường + giới hạn mỗi đảo | Tốc độ cao → ít thời gian phản ứng, nhảy xa hơn |
| Độ khó chunk | Đường cong độ khó mục tiêu + pool của đoạn | Chunk khó: vật cản dày, kết hợp hố + vật trên không |
| Mật độ thử thách | Tỉ lệ chunk khó / chunk nghỉ | Nhịp căng – chùng |

Công thức tốc độ: [physics](../05-technical/05-physics-collision-generation.md#3-tốc-độ-chạy).

## 2. 60 giây đầu tiên của một run

Mục tiêu: người mới không chết trong 10 giây đầu, nhưng tới giây 40–60 phải cảm thấy "suýt chết".

| Thời gian | Nội dung | Mục đích |
|---|---|---|
| 0–3 s | Chạy trên đường trống, nền đẹp, nhạc vào | Cho người chơi nhìn, cảm nhận tốc độ |
| 3–10 s | 2–3 vật thấp cách xa nhau | Dạy "chạm để nhảy" |
| 10–20 s | Vật cao đầu tiên (phải giữ), 1 hàng xu dạy đường nhảy | Dạy "giữ để cao hơn" |
| 20–30 s | Hố đầu tiên, kẻ địch đứng | Thêm loại thử thách mới |
| 30–45 s | Vật trên không đầu tiên (phải nhảy thấp) | Dạy "đừng lúc nào cũng nhảy cao" |
| 45–60 s | Kết hợp 2 loại, item đầu tiên ở chỗ `risky` | Lần "suýt chết" đầu tiên; risk/reward đầu tiên |

Lần chơi đầu (FR-UI-03): ở 3 s đầu tiên hiện bàn tay "chạm để nhảy"; giây 10–20 hiện "giữ để nhảy cao".

Đảo đầu hành trình dùng pool chunk có thẻ `intro` để đảm bảo đúng trình tự trên; các đảo sau không dạy lại.

## 3. Đường cong độ khó

- Mỗi đảo có `difficulty_range` (ví dụ Alabasta 2–4). Trong đảo, độ khó mục tiêu tăng tuyến tính theo % đảo, cộng nhiễu nhỏ ±0.5.
- Đầu mỗi đảo mới: độ khó tụt về đáy khoảng của đảo đó → **khoảng thở** sau đoạn biển, rồi tăng lại. Vì: tạo nhịp sóng; người chơi được "thưởng" khi tới đảo mới.
- Tốc độ không tụt khi sang đảo (chỉ độ khó chunk tụt).

```
độ khó
  5 |                                          ___/
  4 |              ___/|           ___/|   ___/
  3 |      ___/|  /    |  ___/|  /     | /
  2 | ___/     | /     | /    | /      |/
  1 |/         |/      |/     |/
    +----------------------------------------------→ hành trình
     đảo 1  biển  đảo 2  biển  đảo 3  biển  đảo 4
```

## 4. Nhịp căng – chùng

- Sau 2 chunk độ khó ≥ 4 → bắt buộc 1 chunk `breather` (thẻ nghỉ: ít vật cản, nhiều xu).
- Sự kiện boss (`HazardPattern`) luôn được đặt sau một `breather` và theo sau bởi một `breather`.
- Vì: căng liên tục gây mệt và chết vì mất tập trung — cảm giác không công bằng.

## 5. Cảm giác "suýt chết nhưng công bằng" — checklist cho người thiết kế chunk

- [ ] Mọi mối nguy có **thời gian phản ứng ≥ 0.70 s** và tốc độ tiếp cận ≤ 365 px/s ([physics §4](../05-technical/05-physics-collision-generation.md#4-công-bằng-thời-gian-phản-ứng)) — validator kiểm tra. Vật cản không được "xuất hiện" từ tiền cảnh hoặc từ trên xuống không báo trước.
- [ ] Kẻ địch có hành vi được kích hoạt **theo vị trí người chơi**, có báo trước đủ thời gian.
- [ ] Vật rơi/vật bay có **tín hiệu báo trước** (bóng đổ, tiếng, dấu chấm than) ≥ 0.6 s.
- [ ] Không có chỗ mà cách duy nhất là phản xạ dưới 0.25 s.
- [ ] Item `risky` thật sự rủi ro nhưng lấy được bằng một thao tác hợp lý.
- [ ] Validator báo xanh ở mọi tốc độ của chunk.
- [ ] **Trừ chunk `breather`/`intro`**, có ít nhất một chướng ngại/hố trong khoảng ~80–100 px tính từ **mỗi đầu** chunk (không chỉ dồn vào giữa). Vì: đuôi một chunk cộng đầu chunk kế tiếp là khoảng người chơi thật sự trải nghiệm liên tục; dồn nội dung vào giữa khiến khoảng này luôn trống bất kể ghép với chunk nào (D-034). Kiểm tra bằng `tests/unit/runner/test_chunk_pacing.gd` (khoảng trống lớn nhất trên nhiều seed ≤ 450 px).

## 6. Cách chỉnh (tuning) trong M1/M3

1. Dùng chế độ debug: thanh trượt tốc độ, nhập seed, nhảy tới đoạn.
2. Ghi lại: người chơi thử chết ở đâu (log vị trí chết theo chunk id). Chunk có tỉ lệ chết cao bất thường → xem lại.
3. Mỗi lần đổi thông số vật lý → chạy lại validator toàn bộ chunk (vì tầm nhảy thay đổi).
4. Ghi thông số mới vào [physics](../05-technical/05-physics-collision-generation.md) và lý do vào decision log.
