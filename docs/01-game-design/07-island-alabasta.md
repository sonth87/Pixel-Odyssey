# Đặc tả đảo: Alabasta (vertical slice M3)

Alabasta là đảo dùng để chứng minh **công thức sản xuất một đảo**. Mọi đảo sau làm theo cấu trúc của file này (sao chép file, đổi nội dung).

## 1. Thông số chung

| Thuộc tính | Giá trị (`ĐỀ XUẤT`) |
|---|---|
| Độ dài | 2.000 m |
| Thời gian ước tính | ~2.8 phút khi chạy độc lập (M3); ~2 phút trong hành trình phát hành |
| Khoảng độ khó | 2 → 4 |
| Tốc độ | 160 → 230 px/s khi chạy độc lập (M3); 255 → 300 px/s trong hành trình phát hành ([physics §3](../05-technical/05-physics-collision-generation.md#3-tốc-độ-chạy)) |
| Hành vi kẻ địch, NPC | [obstacles/enemies/NPC §7](08-obstacles-enemies-npc.md#7-danh-sách-alabasta) |
| Giới hạn item quý | tối đa 2 trái ác quỷ, 2 item biến hình |
| Nhạc | "Alabasta" — chiptune âm giai Ả Rập; đoạn 5 thêm lớp trống trận |
| Bảng màu chủ đạo | cát vàng cam, đá sa thạch, trời xanh nhạt nóng; Rainbase có ánh đèn casino; Alubarna trắng ngà + xanh ngọc |

## 2. Năm đoạn

Theo yêu cầu: 5 chặng × 20%, bối cảnh cố định, chướng ngại vật ngẫu nhiên có kiểm soát.

### Đoạn 1 — Sa mạc mở (0–20%, 0–400 m)

| Mục | Nội dung |
|---|---|
| Cảm giác | Mênh mông, nắng gắt, vắng người. Khởi động. |
| Nền xa | Trời xanh nhạt gần như trắng ở chân trời, mặt trời to, núi đá mesa xa |
| Nền giữa | Đụn cát nối nhau, vài khối đá |
| Nền gần | Xương rồng, xương thú, cát bay |
| Mặt đất | Cát, gợn sóng; hố cát lún |
| NPC nền | Thưa: 1 đoàn lạc đà rất xa, kền kền bay vòng |
| Chướng ngại vật | Xương rồng thấp (`ground_low`), tảng đá (`ground_low`/`ground_tall`), hố cát lún (`gap`), kền kền sà thấp (`air`), lính Baroque Works "Billions" đứng (`enemy_static`) |
| Chunk | Độ khó 1–3, thẻ `open_desert`; ít bậc địa hình |
| Item | Xác suất điểm đặt 30% |
| Ambience | Gió sa mạc, cát rít nhẹ |
| Sự kiện | — |

### Đoạn 2 — Rainbase, thành phố của Crocodile (20–40%)

| Mục | Nội dung |
|---|---|
| Cảm giác | Thành phố giàu có giữa sa mạc, casino hình cá sấu |
| Nền xa | Trời chiều cam, casino Rain Dinners (mái hình cá sấu vàng) |
| Nền giữa | Nhà mái vòm, đèn lồng, cây cọ |
| Nền gần | Sạp hàng, cột đèn, dân đi lại |
| Mặt đất | Đá lát + cát |
| NPC nền | Vừa: dân mặc áo choàng trắng, thương nhân, lạc đà chở hàng |
| Chướng ngại vật | Thùng gỗ, chum gốm (`ground_low`), sạp chợ (`ground_tall`), lính Billions chạy tới (`enemy_moving`), bậc thềm nhà (`terrain_step`), xe kéo (`ground_wide`) |
| Chunk | Độ khó 2–3, thẻ `city`, có bậc địa hình |
| Sự kiện | **Crocodile** đứng trên mái casino ở nền xa ~5 s, cát xoáy quanh — `BackgroundEvent`, ở 60% đoạn |
| Ambience | Tiếng chợ, nhạc casino xa |

### Đoạn 3 — Yuba, ốc đảo bị chôn vùi (40–60%)

| Mục | Nội dung |
|---|---|
| Cảm giác | Thị trấn hoang tàn bị cát lấp, gió cát |
| Nền xa | Bão cát mờ ở chân trời |
| Nền giữa | Nhà đổ nát nửa chìm trong cát, giếng khô |
| Nền gần | Cột gãy, vải rách bay |
| Mặt đất | Cát dày + mái nhà nhô lên (bậc) |
| NPC nền | Rất thưa: ông Toto đào giếng (1 NPC đặc biệt, đứng yên), vài người đi tị nạn |
| Chướng ngại vật | Mái nhà đổ (`terrain_step`), cột gãy (`ground_tall`), hố cát (`gap`), gạch rơi (`falling`), cát xoáy nhỏ (`hazard`, đứng yên) |
| Chunk | Độ khó 2–4, thẻ `ruins` |
| Item | Xác suất điểm đặt 35% |
| Sự kiện | Gió cát mạnh lên ở 50% đoạn (hạt cát bay ngang tiền cảnh — **không** che vùng chơi) |
| Ambience | Gió hú |

### Đoạn 4 — Sa mạc và sông Sandora (60–80%)

| Mục | Nội dung |
|---|---|
| Cảm giác | Tăng tốc, nguy hiểm hơn, tiến về thủ đô |
| Nền xa | Thủ đô Alubarna thấp thoáng trên vách đá xa — **gợi ý đích đến** |
| Nền giữa | Sông Sandora, bờ đá |
| Nền gần | Lau sậy, đá ven sông |
| Mặt đất | Cát + đá; đoạn có cầu gỗ |
| NPC nền | Đội quân nổi dậy cưỡi ngựa phi ở nền giữa (chạy cùng chiều) |
| Chướng ngại vật | Cá sấu Sandora nhảy lên từ sông (`enemy_moving`, có bọt nước báo trước), cầu gãy (`gap`), đá (`ground_*`), Baroque Works số hiệu (Mr. 5/Miss Valentine dạng lính thường — `enemy_static`) |
| Chunk | Độ khó 3–4, thẻ `river` |
| Sự kiện | **Lưỡi cát (Desert Spada)** — `HazardPattern` 10–15 s ở 50% đoạn: cảnh báo cát xoáy dưới đất bên phải 1 s → lưỡi cát quét từ phải sang dọc mặt đất → phải nhảy qua; lặp 3–4 lần với khoảng cách khác nhau |
| Ambience | Nước chảy, gió |

### Đoạn 5 — Alubarna, thủ đô (80–100%)

| Mục | Nội dung |
|---|---|
| Cảm giác | Cao trào: chiến trường giữa quân nổi dậy và quân hoàng gia, đông nhất |
| Nền xa | Cung điện, tháp đồng hồ |
| Nền giữa | Nhà trắng ngà mái vòm, cờ, khói bụi chiến trận |
| Nền gần | Binh lính hai phe xô đẩy, cây cọ |
| Mặt đất | Đá lát, bậc thang lên cung điện |
| NPC nền | Đông: lính hoàng gia, quân nổi dậy, dân chạy |
| Chướng ngại vật | Lính Marine (`enemy_static`), lính Billions (`enemy_moving`), thùng hàng, bậc thang (`terrain_step`), đạn pháo bay ngang (`air`), xà nhà đổ (`falling`) |
| Chunk | Độ khó 3–4, thẻ `capital` |
| Sự kiện | Ở 70% đoạn: tháp đồng hồ ở nền xa — quả bom bay lên trời và nổ thành ánh sáng lớn (`BackgroundEvent`, tôn trọng tuỳ chọn giảm nhấp nháy) |
| Ambience | Tiếng hô, tiếng kiếm, trống |

### Lối ra — Bờ biển (cuối đảo)

Chunk cố định `alabasta_exit`: cảng Nanohana → mép bến → Going Merry neo cách một cú nhảy chạm (có dư 20%) → đoạn biển.

## 3. Đoạn biển sau Alabasta

| Mục | Nội dung |
|---|---|
| Độ dài | ~25 s ở tốc độ hiện tại |
| Tàu | Going Merry |
| Nền | Biển xanh đậm, chân trời, mây; đảo Alabasta lùi dần ở đầu; đảo kế tiếp hiện dần ở cuối |
| Chướng ngại vật | Thùng trên boong (`ground_low`), cột buồm/dây (`ground_tall`), đạn pháo từ tàu Marine ở nền (`air`, có bóng báo trước), sóng hắt lên boong (`hazard`) |
| Nhạc | "Biển" — nhẹ nhàng hơn, giai điệu phiêu lưu |
| Ambience | Sóng, hải âu, gỗ tàu kẽo kẹt |

## 4. Danh sách asset cần làm (M3)

Đặc tả hình + prompt cho từng mục: [environment](../02-art/03-environment-parallax-spec.md), [obstacles/items/VFX](../02-art/04-obstacles-items-vfx-ui-spec.md).

| Nhóm | Số lượng ước tính |
|---|---|
| Lớp parallax (5 đoạn × 4–5 lớp + biển) | ~25 tấm |
| Mảnh chuyển tiếp giữa đoạn | ~12 |
| Tileset mặt đất (cát, đá lát, cầu, sàn tàu) | 4 bộ |
| Chướng ngại vật tĩnh | ~14 |
| Kẻ địch có animation | 5 (Billions, Marine, cá sấu Sandora, kền kền, lính nổi dậy dạng NPC) |
| NPC nền có animation | ~8 |
| Sự kiện: Crocodile, lưỡi cát, bom tháp đồng hồ | 3 |
| Tàu Going Merry (sàn chơi + hình nền) | 1 bộ |
