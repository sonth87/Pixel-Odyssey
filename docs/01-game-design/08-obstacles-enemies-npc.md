# Chướng ngại vật, kẻ địch, NPC — hành vi

File này quy định **mỗi thực thể trên đường chạy hoạt động thế nào**. Cách chúng **tương tác với người chơi** (chết, vỡ khiên, bị phá, bị đạp...) nằm ở [luật tương tác](09-interaction-rules.md). Giới hạn kích thước/tốc độ để đảm bảo công bằng nằm ở [physics](../05-technical/05-physics-collision-generation.md).

## 1. Ba nhóm thực thể

| Nhóm | Ảnh hưởng gameplay | Ví dụ | Ở lớp |
|---|---|---|---|
| **Chướng ngại vật** | Có — chạm là nguy hiểm | Thùng, xương rồng, hố, bậc, gạch rơi | L5 |
| **Kẻ địch** | Có — chướng ngại vật **có hành vi** (di chuyển, tấn công, báo trước) | Lính Billions, Marine, cá sấu, kền kền | L5 |
| **NPC** | **Không bao giờ** | Dân, lạc đà, quân nổi dậy ở nền | L3, L4 |

Boss **không** phải kẻ địch: boss là sự kiện nền hoặc mẫu chướng ngại đặc biệt — xem [run & stages §7](02-run-journey-and-stages.md#7-sự-kiện-boss).

Về code, chướng ngại vật và kẻ địch là **cùng một loại đối tượng** (`Obstacle`), khác nhau ở dữ liệu: chướng ngại vật có hành vi `STATIC`, kẻ địch có hành vi khác. Vì: một hệ thống va chạm, một pool, một validator.

## 2. Vòng đời của một chướng ngại vật / kẻ địch

```
POOLED ──(chunk được dựng, ngoài màn hình bên phải)──► SPAWNED
SPAWNED ──(vào màn hình)──► VISIBLE (animation idle)
VISIBLE ──(người chơi tới gần ≤ trigger_distance)──► TELEGRAPH (báo trước)
TELEGRAPH ──(hết thời gian báo trước)──► ACTIVE (di chuyển / tấn công)
ACTIVE ──(qua khỏi người chơi)──► PASSED ──(ra khỏi mép trái)──► POOLED
ACTIVE/VISIBLE ──(bị phá / bị đạp)──► DEFEATED (animation văng ra) ──► POOLED
```

- Chướng ngại tĩnh bỏ qua TELEGRAPH/ACTIVE.
- **Kích hoạt theo vị trí, không theo thời gian** (D-025): điều kiện chuyển VISIBLE → TELEGRAPH là *khoảng cách từ người chơi tới vật*, kiểm tra mỗi tick. Vì: cùng một chunk ở mọi tốc độ cho cùng một "cảnh huống", validator kiểm tra được, và mọi người chơi gặp tình huống giống nhau với cùng seed.
- Thời gian báo trước và chuyển động sau khi kích hoạt đo bằng **tick**.
- Các thông số ngẫu nhiên (pha tuần tra, biến thể hình) được quyết định **lúc dựng chunk** bằng luồng RNG `chunks`, không quyết định lúc kích hoạt.

## 3. Báo trước (telegraph)

Mọi thứ có thể "bất ngờ" phải được báo trước bằng **hình** (bắt buộc) và **âm** (nên có):

| Tình huống | Tín hiệu hình | Thời gian tối thiểu |
|---|---|---|
| Kẻ địch sắp lao tới | Animation `telegraph` (thu người, giơ vũ khí) | 0.25 s |
| Vật rơi từ trên | Bóng đổ ở điểm rơi, to dần | 0.6 s |
| Vật bay/đạn vào từ mép phải ở độ cao nguy hiểm | Dấu "!" ở mép phải đúng độ cao đó | 0.6 s |
| Vật nhảy lên từ dưới (nước, cát) | Bọt nước / cát sủi ở điểm bật | 0.6 s |
| Mối nguy quét mặt đất | Cát xoáy ở mép phải mặt đất | 1.0 s |
| Bắn | Nòng/tay loé sáng (tôn trọng giảm nhấp nháy: đổi màu thay vì chớp) | 0.5 s |

Thời gian báo trước được validator dùng như một phần của "thời gian phản ứng" — xem [physics §4](../05-technical/05-physics-collision-generation.md#4-công-bằng-thời-gian-phản-ứng).

## 4. Các hành vi

Hành vi là dữ liệu (`ObstacleBehaviorData` và lớp con) — thêm kẻ địch mới chỉ chọn hành vi + tham số. Thêm **hành vi mới** là thay đổi code.

| Hành vi | Mô tả | Tham số | Ràng buộc công bằng | Đạp được (mặc định) |
|---|---|---|---|---|
| `STATIC` | Đứng yên, animation idle | — | Kích thước theo loại | Kẻ địch: có · Vật: không |
| `CHARGER` | Đứng yên tới khi người chơi trong `trigger_distance` → báo trước → chạy về phía người chơi với tốc độ riêng | `trigger_distance` (≥ 160 px), `telegraph_time`, `move_speed` | Tốc độ tiếp cận ≤ trần tiếp cận | Có |
| `PATROL` | Đi qua lại quanh vị trí gốc | `range` (≤ 24 px), `move_speed` (≤ 30 px/s), `phase` (RNG lúc dựng) | Validator thử nhiều pha | Có |
| `LEAPER` | Ẩn dưới nước/cát; khi kích hoạt → báo trước → nhảy vồng theo cung cố định rồi rơi xuống lại | `trigger_distance`, `telegraph_time`, `leap_height`, `leap_duration` | Cung bay cố định; có ít nhất một thời điểm nhảy hoặc chạy qua an toàn | Không |
| `FLYER` | Bay ngang về phía người chơi, nhấp nhô theo hình sin quanh một độ cao | `move_speed`, `band` (thấp/cao), `amplitude` (≤ 6 px), `period` | Luôn nằm trong dải độ cao của nó | Có (đạp từ trên) |
| `SHOOTER` | Đứng yên; khi kích hoạt → báo trước → bắn một viên đạn bay ngang ở dải thấp/cao | `trigger_distance`, `telegraph_time`, `projectile` (một `ObstacleData` loại `air`), `projectile_speed` | Đạn tính vào trần tiếp cận | Có (người bắn); đạn: không |
| `DROPPER` | Vật ở ngoài mép trên; khi kích hoạt → bóng đổ → rơi thẳng xuống điểm định sẵn, sau đó nằm lại thành vật thấp hoặc vỡ biến mất | `trigger_distance`, `warning_time` (≥ 0.6 s), `fall_speed`, `after_landing` (`REMAIN_LOW` / `SHATTER`) | Điểm rơi cố định trong chunk | Không |
| `SWEEPER` | Mối nguy trồi lên ở mép phải, quét dọc mặt đất về phía người chơi | `trigger_distance`, `telegraph_time` (≥ 1.0 s), `move_speed`, chiều cao (≤ 20 px) | Nhảy chạm phải vượt được; tính vào trần tiếp cận | Không |

"Thùng lăn", "lạc đà đi ngược" là `CHARGER` với hitbox thấp/rộng — không cần hành vi riêng.

### 4.1 Độ khó theo hành vi
Cùng một kẻ địch có thể dùng hành vi khác nhau theo bậc khó (khai báo trong `ObstacleSet`): ví dụ lính Billions là `STATIC` ở chunk độ khó 1–2, `CHARGER` ở độ khó 3+. Vì: tăng độ khó mà không cần thêm art.

## 5. Animation của chướng ngại vật / kẻ địch

| Tag | Khi nào | Bắt buộc với |
|---|---|---|
| `idle` | VISIBLE | Mọi kẻ địch |
| `telegraph` | TELEGRAPH | CHARGER, LEAPER, SHOOTER |
| `active` | ACTIVE (chạy, bay, nhảy, bắn) | Mọi hành vi trừ STATIC |
| `defeated` | Bị phá bằng năng lực / khiên — bật văng ra sau, xoay | Kẻ địch; vật có thể dùng VFX vỡ chung |
| `stomped` | Bị đạp — bẹp xuống | Kẻ địch đạp được |

Khi bị hạ: văng theo cung về phía sau-trên, **nhấp nháy 3 lần** rồi biến mất (không dùng mờ dần bằng alpha — giữ pixel art). Hiện số điểm nhỏ bay lên.

Hướng: kẻ địch luôn nhìn sang **trái** (về phía người chơi).

## 6. NPC

### 6.1 Ba hạng NPC
| Hạng | Hoạt động | Ví dụ | Chi phí |
|---|---|---|---|
| **Ambient** | Đứng/đi lại theo vòng lặp, hoàn toàn độc lập | Dân đi chợ, lạc đà | Thấp |
| **Reactive** | Như ambient + **phản ứng** khi có sự kiện gần chúng | Dân vẫy tay khi người chơi chạy qua, bỏ chạy khi có vụ nổ, reo khi Perfect | Thấp (thêm 1–2 animation) |
| **Set-piece** | Xuất hiện cố định tại một % của đoạn, có kịch bản ngắn | Ông Toto đào cát ở Yuba, quân nổi dậy phi ngựa ở Sandora | Trung bình |

### 6.2 Phản ứng (reactive)
| Kích hoạt | Điều kiện | Phản ứng gợi ý |
|---|---|---|
| `player_near` | Người chơi ngang hàng với NPC (theo hệ số parallax của lớp) | Quay nhìn, vẫy tay |
| `perfect` | Có Perfect Jump khi NPC đang trên màn hình | Reo, giơ tay |
| `destroy_near` | Kẻ địch/vật bị phá gần NPC | Giật mình, ngồi thụp |
| `transform` | Người chơi biến hình | Há hốc, chỉ tay |
| `boss_event` | Sự kiện boss bắt đầu | Bỏ chạy về bên trái |

Mỗi NPC reactive có tối đa 2 phản ứng (để giới hạn art). Phản ứng chọn bằng RNG `cosmetic`.

### 6.3 Quy tắc NPC
1. **Không bao giờ** ở lớp gameplay L5, không có hitbox.
2. Không dùng màu/trang phục giống kẻ địch của đoạn đó; tương phản thấp hơn kẻ địch.
3. Không được che chướng ngại vật hoặc vùng nhìn trước của người chơi (NPC L4 cao ≤ 22 px, đứng dưới y=148).
4. Số NPC trên màn hình ≤ 12 (hiệu năng), dùng pool.
5. Mật độ theo đoạn (`thưa`/`vừa`/`đông`) trong dữ liệu đoạn.
6. Mọi ngẫu nhiên của NPC dùng luồng `cosmetic` — không bao giờ ảnh hưởng chuỗi gameplay.

### 6.4 Animation NPC
`idle` (2), `walk` (2–4), `react_<tên>` (2–4) cho NPC reactive. Khung nhỏ hơn nhân vật chính (xem [environment spec §6](../02-art/03-environment-parallax-spec.md#6-npc-nền)).

## 7. Danh sách Alabasta

### 7.1 Kẻ địch & chướng ngại có hành vi
| ID | Loại | Hành vi | Tham số đề xuất | Đạp được | Đoạn |
|---|---|---|---|---|---|
| `billions_grunt` | enemy | STATIC (độ khó 1–2) / CHARGER (3+) | CHARGER: trigger 180 px, báo trước 0.3 s, 50 px/s | Có | 1, 2, 5 |
| `marine_soldier` | enemy | STATIC / SHOOTER (đoạn 5) | SHOOTER: trigger 220 px, báo trước 0.5 s, đạn dải thấp 60 px/s | Có | 5 |
| `sandora_croc` | enemy | LEAPER | trigger 150 px, báo trước 0.6 s, cao 40 px, 0.7 s | Không | 4 |
| `vulture` | air | FLYER | 40 px/s, dải thấp hoặc cao, biên độ 4 px | Có | 1, 3 |
| `banana_wani` | enemy, rộng | CHARGER chậm | trigger 200 px, 25 px/s | Không (quá to) | 2 (hiếm) |
| `wall_cannon` | enemy | SHOOTER | đạn dải cao, 70 px/s | Không | 5 |
| `falling_debris` | falling | DROPPER | cảnh báo 0.7 s, sau khi rơi `REMAIN_LOW` | Không | 3, 5 |
| `sand_whirl` | hazard | STATIC (có animation) | — | Không | 3 |
| `desert_spada` | hazard | SWEEPER | báo trước 1.0 s, 70 px/s, cao 18 px | Không | 4 (sự kiện) |
| `camel_caravan` | ground_wide | CHARGER chậm | 20 px/s | Không | 1, 2 |

### 7.2 NPC
| ID | Hạng | Phản ứng | Đoạn |
|---|---|---|---|
| `townsfolk_robe` | Reactive | vẫy tay (`player_near`), ngồi thụp (`destroy_near`) | 2, 5 |
| `merchant` | Reactive | reo (`perfect`), chỉ tay (`transform`) | 2 |
| `camel_far` | Ambient | — | 1 |
| `refugee` | Ambient | — | 3 |
| `toto_digging` | Set-piece | — (đào cát lặp) | 3 (tại 40%) |
| `rebel_cavalry` | Set-piece | phi ngựa cùng chiều | 4 (tại 20%) |
| `royal_vs_rebel` | Set-piece | nhóm đánh nhau | 5 |
| `child_waving` | Reactive | nhảy vẫy (`player_near`), reo (`perfect`) | 2, 5 |
