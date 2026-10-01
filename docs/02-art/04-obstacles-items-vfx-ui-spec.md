# Đặc tả chướng ngại vật, kẻ địch, item, VFX, UI

Giới hạn kích thước **hitbox** theo loại được định nghĩa ở [physics](../05-technical/05-physics-collision-generation.md#6-giới-hạn-kích-thước-chướng-ngại-vật). Bảng dưới ghi kích thước **hình vẽ** (lớn hơn hitbox một chút).

Ghép prompt: `S-PROP + Content + O-PROP + AVOID` (vật tĩnh), `S-CHAR + Character + Pose + O-STRIP(n) + AVOID` (kẻ địch có animation), `S-VFX + Content + O-STRIP(n) + AVOID` (hiệu ứng). Các khối ở [prompt library](06-prompt-library.md).

## 1. Quy tắc chung cho vật nguy hiểm

1. Mỗi **loại** chướng ngại vật có một **dáng** dễ nhận: vật thấp — bè ngang; vật cao — đứng thẳng; vật trên không — có cánh/bay, có bóng đổ dưới đất; vật rơi — có bóng đổ to dần trước khi rơi.
2. Vật nguy hiểm có tương phản cao hơn nền; có ít nhất một mảng màu "nóng" hoặc đậm.
3. Vật có animation thì frame đầu tiên phải đọc được ngay loại của nó.
4. Mỗi vật có **phiên bản bị phá** (khi người chơi có năng lực phá): 3–4 frame vỡ/bay đi, hoặc dùng VFX vỡ chung.

## 2. Chướng ngại vật Alabasta

| ID | Loại | Hình (px) | Frame | Mô tả |
|---|---|---|---|---|
| `cactus_low` | ground_low | 14×16 | 1 | Xương rồng tròn thấp, gai trắng, xanh xám đậm |
| `rock_small` | ground_low | 18×12 | 1 | Tảng đá sa thạch dẹt |
| `rock_tall` | ground_tall | 18×32 | 1 | Cột đá đứng |
| `barrel` | ground_low | 14×18 | 1 | Thùng gỗ đai sắt |
| `crate_stack` | ground_tall | 16×34 | 1 | Chồng 2 thùng gỗ |
| `jar_pair` | ground_low | 20×14 | 1 | Hai chum gốm |
| `market_stall` | ground_tall | 30×38 | 1 | Sạp chợ có mái vải sọc |
| `cart` | ground_wide | 40×20 | 1 | Xe kéo chở hàng |
| `camel_caravan` | ground_wide | 56×24 | 4 (đi) | 2 lạc đà nối nhau chở hàng, đi chậm ngược chiều |
| `sand_pit` | gap | rộng 24–72 | 2 (cát chảy) | Hố cát lún xoáy — vẽ mép trái/phải + lòng hố |
| `broken_bridge` | gap | rộng 32–64 | 1 | Cầu gỗ gãy trên sông |
| `stone_steps` | terrain_step | 16×8/16/24 | 1 | Bậc đá |
| `ruined_roof` | terrain_step | 48×16 | 1 | Mái nhà nhô lên khỏi cát |
| `falling_debris` | falling | 12×12 | 2 + bóng | Gạch đá rơi, bóng đổ to dần 0.6 s trước |
| `cannonball` | air | 10×10 | 2 | Đạn pháo bay ngang, vệt khói |
| `sand_whirl` | hazard | 16×20 | 4 | Cát xoáy đứng yên |
| `desert_spada` | hazard | 48×20 | 4 | Lưỡi cát quét dọc mặt đất (sự kiện Crocodile) |

Prompt mẫu — `market_stall`:
```
[S-PROP]
Content: a desert market stall with a striped red and cream cloth awning on wooden poles,
a counter piled with fruit and clay pots, about 30x38 pixels, solid and readable.
[O-PROP] [AVOID]
```
Prompt mẫu — `sand_pit` (vẽ 3 mảnh: mép trái, lòng hố lặp, mép phải):
```
[S-PROP]
Content: a quicksand pit seen from the side, cut into flat desert ground: dark swirling sand
inside the hole, crumbling sand edges on the left and right, about 64x24 pixels.
[O-PROP] [AVOID]
```
Prompt mẫu — `falling_debris`:
```
[S-PROP]
Content: a chunk of broken sandstone brick, cracked, about 12x12 pixels.
[O-PROP] [AVOID]
```
Prompt mẫu — `desert_spada`:
```
[S-VFX]
Content: a sharp blade of sand slicing along the ground from right to left, a low wave of
golden sand with a sharp edge and flying grains, about 48x20 pixels.
[O-STRIP(4)] frames: 1) blade emerging, 2) full blade, 3) full blade with grains, 4) blade
with trailing dust. [AVOID]
```

## 3. Kẻ địch Alabasta (chướng ngại vật có animation)

Kẻ địch dùng chuẩn nhân vật (chibi, khung 64×64, cao ~22 px) nhưng ít màu hơn (≤ 10). Tag animation theo hành vi ([obstacles/enemies §5](../01-game-design/08-obstacles-enemies-npc.md#5-animation-của-chướng-ngại-vật--kẻ-địch)); hành vi và tham số ở [§7](../01-game-design/08-obstacles-enemies-npc.md#7-danh-sách-alabasta).

| ID | Loại | Animation | Mô tả |
|---|---|---|---|
| `billions_grunt` | enemy (đạp được) | `idle` 2, `telegraph` 2, `active` (chạy) 4, `defeated` 3, `stomped` 2 | Lính Baroque Works: áo choàng xám, khăn che mặt, đao cong |
| `marine_soldier` | enemy (đạp được) | `idle` 2, `telegraph` 2 (giương súng), `active` 2 (bắn), `defeated` 3, `stomped` 2 | Lính Hải quân: mũ trắng, áo xanh trắng, súng trường |
| `sandora_croc` | enemy | `telegraph` (bọt nước) 2, `active` (nhảy) 4, `defeated` 3 | Cá sấu sông Sandora nhảy vồng lên từ nước |
| `vulture` | air (đạp được) | `active` (bay) 4, `defeated` 3, `stomped` 2 | Kền kền nâu sà ngang |
| `banana_wani` | ground_wide | `idle` 2, `active` (bò) 4, `defeated` 3 | Cá sấu chuối khổng lồ (chỉ ở đoạn Rainbase, hiếm) — 64×32 |

Prompt — `billions_grunt`:
```
[S-CHAR]
Character: a generic desert bandit soldier wearing a grey hooded cloak, a cloth mask over the
mouth, holding a curved saber, dark grey and sand colors, no recognizable face, about 22
pixels tall.
Pose: running to the LEFT toward the viewer's left side, saber raised, menacing.
[O-STRIP(4)] frames: running cycle. [AVOID]
```
(Kẻ địch đi ngược chiều nhân vật → nhìn sang **trái**.)

Prompt — `marine_soldier`:
```
[S-CHAR]
Character: a generic navy soldier with a white sailor cap with a short brim, white and
light-blue uniform, blue scarf, holding a rifle across the chest, about 22 pixels tall.
Pose: standing guard facing LEFT, alert.
[O-STRIP(2)] frames: 1) standing, 2) shifting weight slightly. [AVOID]
```

Prompt — `vulture`:
```
[S-CHAR]
Character: a scruffy brown desert vulture with a bald pink head, wings spread, about 16x12
pixels.
Pose: flying to the LEFT, wing flap cycle.
[O-STRIP(4)] [AVOID]
```

## 4. Item

| ID (trung lập) | One Piece | Hình (px) | Frame | Mô tả |
|---|---|---|---|---|
| `coin` | Xu Berry | 8×8 | 4 (xoay) | Đồng xu vàng có ký hiệu ฿ đơn giản |
| `coin_bag` | Túi Berry | 12×12 | 2 (lấp lánh) | Túi vải buộc dây, xu thò ra |
| `shield_item` | Bong bóng Sabaody | 14×14 | 4 (lơ lửng) | Bong bóng trong, ánh cầu vồng 2 điểm sáng |
| `transform_item` | Thịt có xương | 14×12 | 2 (nhún) | Đùi thịt hoạt hình to, xương trắng hai đầu |
| `devil_fruit` | Trái ác quỷ | 12×14 | 2 | Trái tím có hoa văn xoắn ốc, cuống xoăn. Một hình chung; trái cụ thể chỉ lộ khi ăn |
| `magnet_item` | Log Pose | 12×12 | 2 | Vòng đeo tay có quả cầu thuỷ tinh, kim chỉ |
| `speed_item` | Chai Cola | 8×14 | 2 | Chai cola cổ điển |

Prompt — `transform_item`:
```
[S-PROP]
Content: a big cartoon roasted meat on the bone, juicy brown meat with a highlight, white
bone sticking out on both ends, appetizing, about 14x12 pixels.
[O-PROP] [AVOID]
```
Prompt — `shield_item`:
```
[S-PROP]
Content: a floating soap bubble, a round circle of light cyan pixels with two small white
highlight pixels and a hint of pink and yellow rainbow on the rim, the inside is mostly
empty, about 14x14 pixels.
[O-PROP] [AVOID]
```
Prompt — `devil_fruit`:
```
[S-PROP]
Content: a mysterious magical fruit, purple with swirl patterns on its surface, a curly green
stem on top, about 12x14 pixels.
[O-PROP] [AVOID]
```

Biểu tượng HUD cho từng trái ác quỷ (khi đã ăn): 12×12, mỗi trái một màu/hoa văn riêng (Gomu tím, Mera cam lửa, Hie xanh băng, Pika vàng, Nikyu hồng hình bàn chân, Bari xanh lục khiên).

## 5. VFX

Mọi VFX là sprite animation (không dùng hệ hạt mềm của engine cho thứ cần đúng phong cách; hệ hạt chỉ dùng cho hạt 1×1 px).

| ID | Kích thước | Frame | Khi nào | Mô tả |
|---|---|---|---|---|
| `dust_jump` | 16×8 | 4 | `jump_start` | Bụi bung hai bên chân |
| `dust_land` | 24×8 | 4 | `land` | Bụi toé ngang |
| `dust_run` | 8×6 | 3 | mỗi bước chạy (thưa) | Vệt bụi nhỏ sau gót |
| `perfect_flash` | 32×32 | 5 | Perfect Jump | Ngôi sao 4 cánh bung ra, trắng vàng |
| `pickup_sparkle` | 16×16 | 4 | Nhặt item | Tia lấp lánh |
| `shield_loop` | 32×32 | 4 | Đang có khiên | Bong bóng bao quanh nhân vật |
| `shield_pop` | 32×32 | 5 | Vỡ khiên | Bong bóng vỡ thành giọt |
| `transform_burst` | 64×64 | 6 | Bắt đầu biến hình | Vòng sáng + hơi nước tỏa ra |
| `destroy_burst` | 24×24 | 5 | Phá vật cản | Mảnh vỡ + sao |
| `splash` | 32×24 | 5 | Rơi xuống nước / cá sấu nhảy | Nước toé |
| `sand_burst` | 24×16 | 4 | Rơi hố cát / cát xoáy | Cát toé |
| `speed_lines` | 64×32 | 3 | Tốc độ cao / Pika | Vệt ngang trắng |
| `warning_marker` | 12×12 | 2 | Báo trước vật rơi/bay | Dấu "!" đỏ nhấp nháy |
| `shadow_blob` | 16×4 | 1 (co giãn theo bước 2 px) | Dưới vật rơi/bay | Bóng đổ hình bầu dục |

Prompt — `perfect_flash`:
```
[S-VFX]
Content: a four-pointed star burst sparkle, white center with yellow edges, expanding then
breaking into small square sparks, about 32x32 pixels.
[O-STRIP(5)] frames: 1) tiny star, 2) medium star, 3) biggest star, 4) star breaking into
sparks, 5) few sparks fading. [AVOID]
```
Prompt — `dust_land`:
```
[S-VFX]
Content: a small puff of light sand-colored dust bursting sideways from the ground on landing,
blocky round puffs, about 24x8 pixels.
[O-STRIP(4)] frames: puff appears, expands, breaks apart, fades into 2 tiny pixels. [AVOID]
```

## 6. UI (lưới 640×360 — D-017)

| Phần tử | Kích thước (lưới UI) | Mô tả |
|---|---|---|
| Font | xem [localization](../04-localization/01-localization.md) | Pixel font có đủ dấu tiếng Việt |
| Số quãng đường (HUD) | cao 16 px | Góc trên trái, chữ trắng kem, bóng đổ 1 px nâu đậm |
| Điểm + hệ số combo | cao 12 px | Dưới quãng đường |
| Nút pause | 24×24 | Góc trên phải, vùng chạm thật 48×48 |
| Ô năng lực đang có | 24×24 mỗi ô | Biểu tượng + vòng thời gian còn lại |
| Khung panel (9-slice) | góc 8×8 | Nền kem `#FCF5EA`, viền nâu, bo góc kiểu pixel |
| Nút (9-slice) | cao 32 | 3 trạng thái: thường, nhấn (lún 2 px), khoá |
| Biểu tượng đảo (bản đồ hành trình) | 24×24 | Mỗi đảo một biểu tượng |
| Bàn tay hướng dẫn | 24×24 | 2 frame chạm |
| Chữ PERFECT | 64×16 | Vẽ tay dạng sprite (không dùng font) |

Prompt — khung panel:
```
[S-UI]
Content: a 9-slice friendly dialog panel frame, cream fill (#FCF5EA), a 2-pixel dark brown
border with rounded pixel corners and a 1-pixel lighter inner highlight, empty inside, shown
as a square panel.
[O-PROP] [AVOID]
```
Prompt — nút:
```
[S-UI]
Content: a chunky pixel-art game button, warm orange fill with a darker bottom edge giving a
raised 3D look, dark brown border, rounded pixel corners, empty without text, wide shape.
[O-PROP] [AVOID]
```

## 7. Checklist duyệt

- [ ] Kích thước hình phù hợp giới hạn hitbox của loại.
- [ ] Đọc được loại vật ở 1× trên nền của mọi đoạn nó xuất hiện.
- [ ] Không nhầm với trang trí nền.
- [ ] Có phiên bản bị phá (hoặc gán VFX vỡ chung).
- [ ] Prompt lưu kèm ảnh raw.
