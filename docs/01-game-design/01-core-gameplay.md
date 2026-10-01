# Gameplay cốt lõi

## 1. Vòng lặp chính

```
Chạy tự động → chạm để nhảy → né / vượt → nhặt item → dùng năng lực
      ↑                                                     │
      └── chơi lại ← xem kết quả ← chết ← đi xa hơn ←───────┘
```

Vòng lặp **trong run** (vài giây): thấy chướng ngại vật → quyết định chạm hay giữ, khi nào → vượt qua / chết.
Vòng lặp **giữa các run** (vài phút): chết → thấy mình đi xa hơn/kém hơn kỷ lục → chơi lại ngay.
Vòng lặp **dài hạn** (nhiều ngày): tới được đảo mới lần đầu, mở khoá nhân vật, leo bảng xếp hạng.

## 2. Điều khiển

| Thao tác | Kết quả | Vì sao |
|---|---|---|
| Chạm (nhấn rồi thả nhanh) | Nhảy thấp | Đủ cho chướng ngại vật thấp; tránh được vật cản trên không |
| Giữ | Nhảy cao hơn, tối đa sau một khoảng thời gian giữ | Vượt vật cao, hố rộng |
| Không làm gì | Tiếp tục chạy | |
| Chạm khi đang trên không | Không có tác dụng (trừ nhân vật có nhảy đôi) | Giữ một nút đơn giản |

- Chạm vào **bất kỳ đâu** trên màn hình (trừ nút pause ở góc). Trên PC: phím Space / mũi tên lên / chuột trái.
- **Không có** nút tấn công, cúi, lướt. Mọi chiều sâu đến từ **thời điểm** và **độ dài** giữ.
- Thông số cụ thể (độ cao, thời gian giữ, coyote time, buffer): [physics](../05-technical/05-physics-collision-generation.md).

### Vì sao có "giữ để nhảy cao"?
Brainstorm gốc ghi "tap giữ: có thể cân nhắc". Đề xuất **có**, vì: nếu chỉ có một kiểu nhảy, người chơi chỉ phải quyết định *khi nào*; thêm độ dài giữ thì có thêm quyết định *bao nhiêu* mà vẫn chỉ một nút. Kết hợp với chướng ngại vật trên không (phạt nhảy quá cao), lựa chọn này có ý nghĩa thật. Trạng thái: `ĐỀ XUẤT` — xác nhận sau test M1.

## 3. Nhân vật trên màn hình

- Nhân vật đứng ở vị trí cố định theo chiều ngang (cách mép trái ~64 px logic); thế giới trôi về bên trái. Vì: người chơi luôn nhìn thấy cùng một khoảng phía trước, dễ đọc tình huống.
- Camera theo chiều dọc khi địa hình lên xuống bậc, nhưng mượt và trễ nhẹ để không gây chóng mặt.
- Hướng chạy: luôn trái → phải.

## 4. Chướng ngại vật — phân loại trung lập

Code và thiết kế chỉ dùng các **loại** sau; content pack quyết định nó trông như gì.

| Loại | Code | Cách vượt | Ví dụ One Piece (Alabasta) |
|---|---|---|---|
| Vật thấp | `ground_low` | Chạm | Thùng gỗ, xương rồng thấp, đụn cát nhỏ |
| Vật cao | `ground_tall` | Giữ | Sạp chợ, chồng thùng, tường thấp |
| Vật rộng | `ground_wide` | Giữ, canh sớm | Đoàn lạc đà, xe kéo |
| Kẻ địch đứng | `enemy_static` | Chạm/giữ tuỳ chiều cao | Lính Marine đứng gác |
| Kẻ địch di chuyển | `enemy_moving` | Canh thời điểm (vật đi ngược chiều → tới nhanh hơn) | Lính Baroque Works chạy tới, cá sấu Sandora |
| Vật trên không | `air` | **Không** nhảy cao, hoặc nhảy qua khi nó ở thấp | Kền kền, đạn pháo bay ngang |
| Vật rơi | `falling` | Canh thời điểm | Gạch đá rơi, đầu Buggy (East Blue) |
| Hố | `gap` | Nhảy qua | Hố cát lún, khoảng trống giữa mái nhà, mép đất ra biển |
| Bậc địa hình | `terrain_step` | Nhảy lên / chạy xuống | Bậc thang, mái nhà thấp, sàn tàu |
| Nguy hiểm môi trường | `hazard` | Theo mẫu riêng | Lưỡi cát của Crocodile quét ngang mặt đất |

Nguyên tắc chung:
- Mỗi loại có **một hình dáng nhận diện riêng** (không chỉ khác màu) — NFR-AC-02.
- Kẻ địch là chướng ngại vật **có hành vi** (đứng gác, lao tới, bay, nhảy lên, bắn...); **không** có máu, không đánh nhau. Hành vi chi tiết: [obstacles/enemies/NPC](08-obstacles-enemies-npc.md).
- Tương tác với từng loại (chết, mất khiên, bị phá, bị đạp): [luật tương tác](09-interaction-rules.md).
- Mọi `ground_*` nguy hiểm ở mọi mặt, kể cả mặt trên. Chỉ **địa hình** (bậc, mái, sàn) là đứng lên được.

## 5. Đạp kẻ địch

Rơi từ trên xuống đầu một kẻ địch đạp được → kẻ địch bị hạ, nhân vật nảy lên (giữ nút để nảy cao hơn). Đây là cách duy nhất người chơi chủ động "đánh" kẻ địch mà vẫn chỉ một nút: an toàn thì nhảy qua, mạo hiểm thì đạp để lấy điểm. Điều kiện chính xác: [luật tương tác §5](09-interaction-rules.md#5-đạp-stomp).

## 6. Chết

| Nguyên nhân | Mã | Animation |
|---|---|---|
| Va chạm chướng ngại vật/kẻ địch khi không có bảo vệ | `CONTACT` | `death_hit`: bật ngược ra sau → rơi → `death_lie` (nằm ngửa) |
| Rơi xuống hố/biển | `PIT` | `death_fall` rơi khỏi màn hình; nước/cát bắn |
| Đâm vào cạnh bậc quá cao | `WALL` | `death_hit` |

Sau khi chết: hit-stop ngắn → animation chết (~0.6 s) → màn kết quả. Chạm bất kỳ đâu (sau 0.4 s chống bấm nhầm) → run mới.

**Không có hồi sinh** (D-002).

## 7. Perfect Jump

Vượt qua một vật với khoảng hở rất nhỏ (nhảy muộn vừa kịp, hoặc đáp sớm sát mép sau), hoặc giậm nhảy sát mép hố → PERFECT: chữ bật lên, âm thanh riêng, hạt pixel, rung nhẹ (tắt được), điểm và combo.

- Vì sao: tạo trần kỹ năng. Người mới chỉ cần qua được; người giỏi cố tình nhảy sát để kiếm điểm — và chấp nhận rủi ro.
- Định nghĩa chính xác và điểm: [scoring §3](05-scoring-progression-meta.md#3-perfect-jump--định-nghĩa-chính-xác).

## 8. Risk / reward

Item tốt được đặt ở **điểm đặt item có nhãn mạo hiểm** trong chunk: ví dụ trên cao ngay trước một vật trên không, hoặc giữa hai hố. Người chơi chọn:
- An toàn: bỏ qua.
- Mạo hiểm: nhảy cao/canh chuẩn để lấy → có năng lực → phá vật cản, điểm tăng mạnh.

Chi tiết đặt item: [items](04-items-and-powerups.md).

## 9. Thời lượng

Theo hành trình phát hành đề xuất (6 đảo, ~11 phút nếu không chết — [physics §3.3](../05-technical/05-physics-collision-generation.md#33-bảng-tốc-độ--hành-trình-phát-hành-đề-xuất)):

| Mức | Thời gian một run | Tới đâu |
|---|---|---|
| Người mới | 20 s – 2 phút | Đảo 1–2 |
| Trung bình | 3 – 6 phút | Đảo 3–4 |
| Giỏi | 10 – 20 phút | Hết hành trình, vào vòng lặp khó hơn |

Độ khó và nhịp: [difficulty & pacing](06-difficulty-and-pacing.md).
