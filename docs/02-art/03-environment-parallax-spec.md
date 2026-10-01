# Đặc tả nền, parallax, mặt đất, NPC nền

## 1. Các lớp

Màn hình logic 320×180 (rộng tối đa 400 trên màn hình dài). Thứ tự từ xa tới gần:

| Lớp | Tên code | Hệ số trôi | Kiểu asset | Kích thước gốc | Neo dọc | Nội dung |
|---|---|---|---|---|---|---|
| L0 | `sky` | 0 (đứng yên) | 1 tấm | 400×180 | toàn màn hình | Dải màu trời, mặt trời/trăng (sprite riêng) |
| L1 | `far` | 0.10 | Toàn cảnh lặp (tileable) | 640×100 | đáy ở y=120 | Núi, mesa, đường chân trời thành phố |
| L2 | `mid_far` | 0.25 | Toàn cảnh lặp | 640×80 | đáy ở y=140 | Đụn cát, dãy nhà xa, rừng xa |
| L3 | `mid` | 0.45 | **Mảnh rời** đặt ngẫu nhiên | mỗi mảnh ≤ 64×72 | đáy ở y=146 | Nhà, cây cọ, NPC nền nhỏ (12–16 px) |
| L4 | `near` | 0.70 | Mảnh rời | mỗi mảnh ≤ 48×48 | đáy ở y=148 | Xương rồng, sạp hàng, cột đèn, NPC (18–22 px) |
| L5 | `gameplay` | 1.00 | Tileset + chunk | tile 16×16 | mặt đất y=148 | Mặt đất, chướng ngại vật, nhân vật, item |
| L6 | `foreground` | 1.30 | Mảnh rời, thưa | dải đáy ≤ 22 px cao | y ≥ 158 | Cỏ, đá, cát bay ở mép dưới |

Vì sao hai kiểu asset:
- **Toàn cảnh lặp** (L1, L2): ở xa, trôi chậm, ít ai để ý lặp lại. Một tấm 640 px (gấp đôi màn hình) là đủ.
- **Mảnh rời** (L3, L4, L6): ở gần, trôi nhanh, lặp lại một tấm sẽ lộ ngay. Đặt các mảnh rời bằng bộ sinh trang trí (RNG trang trí, mật độ theo đoạn) → không bao giờ lặp giống hệt; và AI gen một vật đơn lẻ dễ hơn nhiều so với một toàn cảnh tileable.

Hệ số trôi là `ĐỀ XUẤT`; chỉnh bằng mắt ở M3.

## 2. Quy tắc

1. **Mật độ pixel giống nhân vật** — xem [style guide](01-art-style-guide.md#4-mật-độ-pixel-thống-nhất). Vật xa vẽ nhỏ hơn, không thu nhỏ.
2. **Phối cảnh khí quyển bằng màu**: L1 tương phản thấp nhất, ngả màu trời; L4 tương phản cao hơn nhưng vẫn kém L5.
3. **Tương phản gameplay**: nhân vật và chướng ngại vật ở L5 phải nổi bật hơn mọi lớp nền. Kiểm tra bằng cách chuyển ảnh chụp màn hình sang đen trắng: chướng ngại vật vẫn phải tách rõ.
4. **Vùng cấm tiền cảnh (FR-WD-09)**: L6 chỉ được ở y ≥ 158 (dưới mặt đất 10 px). Vật tiền cảnh cao hơn (cây cọ, cột) **chỉ** được đặt trong chunk `breather` và không được nằm trong khoảng 1 giây phía trước bất kỳ chướng ngại vật nào.
5. **Toàn cảnh lặp**: mép trái nối liền mép phải. Kiểm tra trong Pixelorama bằng chế độ lặp ô (*Tile Mode*).
6. **NPC nền không giống chướng ngại vật**: NPC ở L3/L4 nhỏ hơn và nhạt hơn kẻ địch ở L5; không mặc đồng phục giống kẻ địch của đoạn đó. Vì: người chơi không được nhầm trang trí là nguy hiểm.
7. **Không dùng alpha để làm mờ** — làm "mờ xa" bằng màu.

## 3. Chuyển tiếp giữa các đoạn

Ở ranh giới đoạn, mỗi lớp chuyển theo cách riêng:

| Lớp | Cách chuyển |
|---|---|
| L0 trời | Đổi bảng màu dần trong 3 s (nội suy giữa các dải màu cố định, mỗi bước là một bộ màu phẳng) |
| L1, L2 | Một **mảnh chuyển tiếp** 320 px (ví dụ đụn cát → mép thành phố) chèn vào giữa hai toàn cảnh |
| L3, L4 | Bộ sinh trang trí đổi danh sách mảnh; trong 200 px đầu trộn mảnh của cả hai đoạn với mật độ chéo nhau |
| L5 mặt đất | Một tile chuyển tiếp (cát → đá lát) |

## 4. Mặt đất (tileset)

- Tile 16×16. Hàng trên cùng là mặt có chi tiết (cỏ, cát gợn, mép đá), các hàng dưới là đất lặp.
- Mỗi tileset cần: mặt phẳng (3 biến thể), mép trái/mép phải của hố, bậc lên/bậc xuống (cao 8, 16, 24 px), cầu (nếu có), tile chuyển tiếp sang tileset khác.

## 5. Đặc tả Alabasta — mô tả + prompt

Ghép: `S-ENV + [nội dung] + O-LAYER(w,h) + AVOID` cho toàn cảnh; `S-PROP + [nội dung] + O-PROP + AVOID` cho mảnh rời. Đính kèm `luffy_normal.png` để ép mật độ pixel.

### 5.1 Trời (dùng chung, đổi màu theo đoạn)

| Đoạn | Mô tả |
|---|---|
| Sa mạc | 5 dải: xanh nhạt nóng ở trên → gần trắng vàng ở chân trời; mặt trời tròn to 24 px màu kem |
| Rainbase | Chiều: cam → hồng đào → tím nhạt ở trên |
| Yuba | Vàng đục, bụi cát; mặt trời mờ |
| Sandora | Xanh trong, mây trắng khối |
| Alubarna | Xanh, có cột khói xa |

Prompt (ví dụ sa mạc):
```
[S-ENV]
Content: a hot desert sky made of 5 flat horizontal color bands, pale hot blue at the top
fading in steps to an almost white warm yellow at the horizon, a large round pale cream sun
in the upper right, no clouds.
[O-LAYER(16,9)] [AVOID]
```

### 5.2 Đoạn 1 — Sa mạc mở

**L1 far** — mô tả: dãy núi đá mesa đỏ cam xa, đỉnh bằng, 2–3 khối, màu nhạt ngả xanh trời; ảnh `1.jpg` minh hoạ *ý tưởng* (mesa) nhưng phải đơn giản hơn nhiều.
```
[S-ENV]
Content: distant flat-topped red sandstone mesas and buttes along the horizon, very low
contrast, washed out toward the pale sky color, 3 or 4 simple blocky shapes with 2 shades
each, the bottom edge is a flat line of distant sand.
[O-LAYER(32,5)] [AVOID]
```
**L2 mid_far** — đụn cát nối nhau, 2 sắc độ cam vàng, đường viền đụn mềm theo bậc pixel.
```
[S-ENV]
Content: rolling sand dunes in warm yellow-orange, each dune a simple blocky curve with a
light side and a shadow side, gentle and repetitive.
[O-LAYER(8,1)] [AVOID]
```
**L3 mid (mảnh rời)**: khối đá sa thạch (3 biến thể), bộ xương cá voi cát, đoàn lạc đà rất nhỏ (NPC 10 px, 2 frame).
```
[S-PROP]
Content: a small weathered sandstone rock formation, warm orange with a darker shadow side,
about 40x30 pixels.
[O-PROP] [AVOID]
```
**L4 near**: xương rồng cao (trang trí, khác xương rồng chướng ngại vật: nhạt hơn, ở nền), xương sọ bò, bụi khô.
```
[S-PROP]
Content: a tall desert cactus with two arms, muted sage green with a darker shade, about
20x36 pixels, slightly faded colors because it is in the background.
[O-PROP] [AVOID]
```
**L6 foreground**: viền cát gợn, đá sỏi nhỏ ở mép dưới.

### 5.3 Đoạn 2 — Rainbase

**L1 far**: casino Rain Dinners — toà nhà mái vòm có tượng cá sấu vàng lớn trên nóc, đứng giữa các mái vòm khác; nền trời chiều.
```
[S-ENV]
Content: a distant desert city skyline at sunset: dome-roofed sandstone buildings and one
large casino building with a big golden crocodile statue on its roof in the middle, simple
blocky silhouettes, low contrast, warm orange and purple tones.
[O-LAYER(32,5)] [AVOID]
```
**L2 mid_far**: dãy nhà đá thấp, cửa sổ vòm, đèn lồng.
**L3 mid**: nhà mái vòm (3 biến thể), cây cọ, đèn lồng treo, NPC dân áo choàng trắng (12–14 px).
```
[S-PROP]
Content: a small two-story sandstone house with a white dome roof, arched dark window and
a striped cloth awning, warm sunset lighting, about 48x56 pixels.
[O-PROP] [AVOID]
```
**L4 near**: sạp trái cây (trang trí), chum gốm, cột đèn, lạc đà chở hàng.

### 5.4 Đoạn 3 — Yuba

**L1 far**: bão cát mờ ở chân trời — khối bụi vàng xám.
**L2 mid_far**: nhà đổ nát chìm nửa trong cát.
```
[S-ENV]
Content: ruined sandstone houses half buried in sand, broken walls and collapsed roofs,
sand drifts covering everything, dusty muted yellow-grey colors, abandoned town.
[O-LAYER(8,1)] [AVOID]
```
**L3 mid**: giếng khô, cột gãy, vải rách treo; NPC đặc biệt: ông lão đào cát (16 px, 2 frame xúc cát).
**L4 near**: thùng gỗ vỡ, mái nhà nhô lên.

### 5.5 Đoạn 4 — Sa mạc & sông Sandora

**L1 far**: vách đá cao, trên đỉnh xa là thủ đô Alubarna (nhỏ, trắng ngà) — **gợi ý đích đến**.
**L2 mid_far**: dòng sông xanh ngọc, bờ đá.
```
[S-ENV]
Content: a wide calm turquoise river crossing a desert, rocky sandstone banks, a few reeds,
simple flat water with 2 shades and small white sparkle pixels.
[O-LAYER(8,1)] [AVOID]
```
**L3 mid**: quân nổi dậy cưỡi ngựa phi (NPC 16 px, 4 frame, **chạy cùng chiều** với tốc độ riêng).
**L4 near**: lau sậy, tảng đá ven sông.

### 5.6 Đoạn 5 — Alubarna

**L1 far**: cung điện và tháp đồng hồ trên vách đá.
```
[S-ENV]
Content: a royal desert palace on top of a cliff with a tall clock tower, white-cream walls
with turquoise domes, distant and low contrast, smoke columns rising from the city below.
[O-LAYER(32,5)] [AVOID]
```
**L2 mid_far**: phố nhà trắng ngà mái vòm xanh ngọc, cờ.
**L3 mid**: lính hoàng gia và quân nổi dậy đánh nhau (nhóm NPC 3–4 người, 2 frame), cây cọ.
**L4 near**: thùng hàng đổ, xe hỏng, bậc thang đá trang trí.

### 5.7 Biển (Going Merry)

| Lớp | Mô tả |
|---|---|
| L0 | Trời xanh, mây khối |
| L1 | Đường chân trời biển, đảo xa (ở đầu: Alabasta lùi dần; ở cuối: đảo mới hiện dần — mảnh riêng) |
| L2 | Biển xanh đậm, sóng khối, hải âu |
| L3 | Tàu khác, tàu Marine (nguồn đạn pháo), Sea King nhô lên thỉnh thoảng (trang trí) |
| L5 | **Sàn tàu** Going Merry làm mặt đất (tileset gỗ), lan can, cột buồm |
| L6 | Sóng bắn ở mép dưới |

```
[S-PROP]
Content: the side view of a small cute pirate caravel with a sheep figurehead, white sails,
light brown wooden hull, the deck is flat and long, about 300x90 pixels.
[O-PROP] [AVOID]
```

## 6. NPC nền

| Lớp | Cao | Frame | Ghi chú |
|---|---|---|---|
| L3 | 12–16 px | 2 (đứng/đi) | Rất đơn giản, 4–5 màu |
| L4 | 18–22 px | 2–4 | Gần bằng nhân vật nhưng nhạt hơn, không có tương phản mạnh |

Prompt NPC (ví dụ dân Alabasta):
```
[S-CHAR]
Character: a simple desert townsperson wearing a long white hooded robe and sandals, tan
skin, about 16 pixels tall, very few colors, slightly faded because it stands in the
background.
Pose: walking to the left, 2 frames.
[O-STRIP(2)] [AVOID]
```

## 7. Số lượng asset — xem [Alabasta](../01-game-design/07-island-alabasta.md#4-danh-sách-asset-cần-làm-m3).
