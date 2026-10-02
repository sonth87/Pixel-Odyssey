# Đặc tả animation nhân vật

## 1. Nguyên tắc

1. **Mọi nhân vật dùng cùng bộ tên trạng thái** (FR-CH-02). Code gọi `play("jump_rise")`, không bao giờ `play("luffy_jump")`.
2. Tên trạng thái = tên **tag** trong file Pixelorama = tên file dải PNG xuất ra = tên animation trong Godot. Viết thường, gạch dưới.
3. Mỗi trạng thái ghi rõ: dùng trong game 1, game 2 hay cả hai; mức ưu tiên; số frame; FPS; lặp hay không; khung.
4. Chiêu thức chia **startup / active / recovery** (D-010).
5. Số frame là **đề xuất tối thiểu**; ít frame mà tư thế rõ tốt hơn nhiều frame mà nhoè.

Mức ưu tiên:
- **B1** — bắt buộc cho game 1, cần ở milestone của nhân vật đó (Luffy: M2).
- **B2** — cần cho game 1 nhưng có thể làm sau (menu, kết quả).
- **G2** — chỉ cần cho game 2, vẽ khi bắt đầu game 2 (ghi sẵn để không quên).

## 2. Bảng trạng thái

### 2.1 Di chuyển cơ bản

| Tag | Mô tả | Ưu tiên | Frame | FPS | Lặp | Khung |
|---|---|---|---|---|---|---|
| `idle` | Đứng thở, nhún nhẹ | B1 | 4 | 6 | ✔ | 64 |
| `run` | Chạy | B1 | 6 | 12* | ✔ | 64 |
| `run_fast` | Chạy nhanh: thân ngả chéo rõ (đầu lệch trước hông 5 px, độ lệch tăng dần từ hông lên đầu), sải dài hơn, gối nhấc cao hơn, tay vung rộng hơn. Game chuyển sang khi tốc độ gốc ≥ 250 px/s (`ĐỀ XUẤT`) | B1 | 6 | 15 | ✔ | 64 |
| `jump_start` | Lấy đà rời đất | B1 | 2 | 15 | ✘ | 64 |
| `jump_rise` | Đang bay lên | B1 | 2 | 10 | ✔ | 64 |
| `jump_apex` | Đỉnh cú nhảy | B1 | 1 | — | ✘ | 64 |
| `fall` | Đang rơi | B1 | 2 | 10 | ✔ | 64 |
| `land` | Chạm đất (lún) | B1 | 2 | 15 | ✘ | 64 |
| `double_jump` | Nhảy lần 2 trên không (nhân vật có nhảy đôi) | B1 (Sanji) | 4 | 15 | ✘ | 64 |
| `walk` | Đi bộ | G2 | 6 | 10 | ✔ | 64 |
| `dash` | Lướt nhanh | G2 | 3 | 15 | ✘ | 64 |
| `crouch` | Ngồi xổm / cúi | G2 | 2 | 10 | ✘ | 64 |

\* FPS của `run` co giãn theo tốc độ chạy: `fps = 12 × (speed / speed_start)`, tối đa 20.

### 2.2 Tư thế tĩnh / trạng thái cơ thể

| Tag | Mô tả | Ưu tiên | Frame | FPS | Lặp | Khung |
|---|---|---|---|---|---|---|
| `sit` | Ngồi (trên lan can tàu, bậc thềm) — màn chọn nhân vật, menu | B2 | 1 | — | ✘ | 64 |
| `sit_idle` | Ngồi đung đưa chân | B2 | 4 | 6 | ✔ | 64 |
| `lie_prone` | Nằm sấp | G2 (B2 nếu dùng cho chết úp mặt) | 1 | — | ✘ | 64 |
| `lie_supine` | Nằm ngửa | B1 (dùng làm `death_lie`) | 1 | — | ✘ | 64 |
| `get_up` | Đứng dậy từ nằm | G2 | 4 | 10 | ✘ | 64 |
| `cheer` | Ăn mừng (kỷ lục mới, màn kết quả) | B2 | 4 | 8 | ✔ | 64 |
| `taunt` | Tạo dáng riêng của nhân vật (màn chọn nhân vật) | B2 | 4 | 8 | ✔ | 64 |

### 2.3 Bị đánh / chết

| Tag | Mô tả | Ưu tiên | Frame | FPS | Lặp | Khung |
|---|---|---|---|---|---|---|
| `hurt` | Bị va chạm nhưng còn sống (vỡ khiên) — giật lùi | B1 | 2 | 12 | ✘ | 64 |
| `death_hit` | Va chạm chết: bật ngửa ra sau | B1 | 3 | 12 | ✘ | 64 |
| `death_lie` | Nằm bất động sau khi chết (= `lie_supine`, mắt xoắn ốc nếu muốn) | B1 | 1 | — | ✘ | 64 |
| `death_fall` | Rơi xuống hố/biển: tay chân quờ quạng | B2 | 2 | 10 | ✔ | 64 |
| `knockback` | Bị đánh văng | G2 | 3 | 12 | ✘ | 64 |
| `knockdown` | Bị đánh ngã (sấp hoặc ngửa) | G2 | 2 | 10 | ✘ | 64 |
| `block` | Đỡ đòn | G2 | 2 | 10 | ✘ | 64 |

### 2.4 Item / biến hình

| Tag | Mô tả | Ưu tiên | Frame | FPS | Lặp | Khung |
|---|---|---|---|---|---|---|
| `pickup` | Phản ứng khi nhặt item (giơ tay / ăn) — có thể phát chồng lên `run` dạng nhanh | B2 | 2 | 12 | ✘ | 64 |
| `eat` | Ăn thịt (trước biến hình) | B1 (Luffy) | 3 | 12 | ✘ | 64 |
| `transform_enter` | Biến hình (phồng lên, hơi nước...) | B1 | 6 | 15 | ✘ | 96 |
| `transform_exit` | Trở về dạng thường | B1 | 4 | 15 | ✘ | 96 |
| `form_*` | **Bộ animation thứ hai** của dạng biến hình: `form_idle`, `form_run`, `form_jump_rise`, `form_fall`, `form_land`, `form_attack` | B1 | như dạng thường | | | 96 |

### 2.5 Chiêu thức (skill 1–5)

Mỗi skill `skill_N` (N = 1..5) có 3 tag:

| Tag | Pha | Mô tả chung | Frame | FPS |
|---|---|---|---|---|
| `skill_N_startup` | Chuẩn bị | Lấy đà, thu tay/kiếm, tụ lực. Người xem đoán được sắp ra đòn gì | 2–3 | 12 |
| `skill_N_active` | Hiệu lực | Đòn bung ra hết cỡ — frame mạnh nhất, thường dùng khung rộng | 2–4 | 15 |
| `skill_N_recovery` | Thu chiêu | Thu về, mất thăng bằng nhẹ, trở về tư thế sẵn sàng | 2–3 | 12 |

Trong game 1: skill được gán vai trò (`transform_attack`, `passive_visual` — xem [characters](../01-game-design/03-characters-and-skills.md)) mới phải vẽ ở milestone của nhân vật; skill khác là **G2**.

Vì sao chia pha: ở game 2, vùng gây sát thương chỉ bật trong `active`; người chơi có thể bị đánh trong `startup`/`recovery`. Vẽ chia pha ngay bây giờ tốn thêm rất ít, đỡ phải vẽ lại.

### 2.6 Đòn đánh thường

| Tag | Mô tả | Ưu tiên | Frame |
|---|---|---|---|
| `attack_1_startup/active/recovery` | Đòn 1 của combo | G2 | 2/2/2 |
| `attack_2_*` | Đòn 2 | G2 | 2/2/2 |
| `attack_3_*` | Đòn 3 (kết thúc combo) | G2 | 2/3/3 |
| `air_attack_*` | Đánh trên không | G2 | 2/2/2 |

### 2.7 Tổng số frame ước tính

| Phạm vi | Frame / nhân vật |
|---|---|
| Game 1 bắt buộc (B1) | ~35–45 (gồm dạng biến hình) |
| Game 1 đầy đủ (B1 + B2) | ~55–65 |
| Game 2 thêm (G2) | ~80–110 |

## 3. Nguyên tắc dáng (rút từ ảnh mẫu)

Ảnh mẫu dáng: `sample/image copy 2.png` (bảng sprite "Runa": đứng, đi, chạy, nhảy, rơi), `sample/image.png` (một frame chạy), `sample/image copy.png` (bảng sprite cậu bé áo choàng). Khi gen ảnh AI cho một tư thế, **đính kèm ảnh mẫu dáng tương ứng** cùng ảnh nhận diện nhân vật.

Nguyên tắc chung:
- **Nhìn nghiêng thật**: đầu, mặt, thân quay hẳn sang phải (một mắt, mũi/miệng ở mép phải, tóc ra sau). Đây là yếu tố lớn nhất khiến dáng chạy/đi đọc được. Thân nhìn thẳng mà chân chạy ngang sẽ luôn trông gượng.
- **Đường nét hành động**: mỗi frame có một hướng chủ đạo rõ (chạy: chéo về trước; nhảy lên: thẳng đứng kéo dài; rơi/đáp: co tròn).
- **Tương phản lớn giữa các frame**: tay chân thay đổi vị trí nhiều pixel, không nhích 1 px.

| Trạng thái | Thân | Chân | Tay |
|---|---|---|---|
| `idle` | Thẳng, nhún 1 px | Hai chân hơi dạng, thẳng | Buông, có thể nắm hờ |
| `walk` (G2) | **Thẳng đứng**, nhún nhẹ | Hình chữ "V" hẹp kiểu kéo kéo, gối gần thẳng, gót chạm đất trước | Vung nhỏ, gần thân, khuỷu gần thẳng |
| `run` | **Đổ về trước rõ** | **Xoạc rộng** (khoảng cách hai bàn chân ≈ 0.5–0.6 chiều cao nhân vật); chân sau duỗi ra sau, **bàn chân sau đá cao** (ngang gối hoặc hông); chân trước gối gập, cẳng chân chéo xuống trước. Hầu như mọi frame đều có một chân sau đá cao; frame "lướt qua" chân gập gọn dưới hông | **Khuỷu gập ~90°, nắm đấm**: tay trước nắm ngang ngực/cằm, tay sau khuỷu kéo ra sau lưng; ngược chiều chân |
| `run_fast` | Đổ sâu hơn `run` | Xoạc rộng hơn, đá cao hơn | Vung mạnh hơn |
| `jump_start` | Ngồi thụp (lấy đà) | **Gối gập sâu**, hai bàn chân đặt sát | Tay kéo xuống sau |
| `jump_rise` | **Duỗi thẳng đứng**, kéo dài | Hai chân khép, duỗi thẳng xuống, mũi chân chúc | **Một tay vươn thẳng lên trời** |
| `jump_apex` | Hơi co | **Gối co lên trước bụng** (thu chân) | Tay mở hai bên giữ thăng bằng |
| `fall` | Hơi ngả | Chân duỗi xuống chuẩn bị đáp, có thể lệch nhau | Tay giơ lên ngang vai |
| `land` | Ngồi thụp như `jump_start` | Gối gập sâu hấp thụ lực | Tay ra trước |
| `death_hit` / `knockback` | Văng ngửa, nghiêng mạnh | Tay chân **xoè tung** về phía sau | Như chân |

Đo trên Luffy (22–24 px): xoạc chạy ≈ 11–13 px, bàn chân sau đá lên tới hàng ngang gối/hông (cách đất 4–6 px), thân đổ: đầu lệch trước hông 2 px (chạy) / 5 px (chạy nhanh), độ lệch tăng dần theo từng tầng từ hông lên đầu.

## 4. Mô tả chi tiết và prompt tư thế

Prompt tư thế (khối `P-*`) ghép theo [prompt library](06-prompt-library.md): `S-CHAR + C-<NHÂN VẬT> + P-<TƯ THẾ> + O-... + AVOID`. Với frame thứ hai trở đi nên dùng `O-EDIT` từ frame `idle` đã duyệt.

### `idle`
- **Mô tả**: đứng thẳng, hai chân rộng bằng vai, tay buông tự nhiên. Frame 1–2: thẳng; frame 3: thân hạ 1 px (thở ra); frame 4: như 2. Đầu/mũ đi theo thân. Tính cách: Luffy cười tươi, Zoro khoanh tay hoặc tay đặt lên kiếm, Nami tay chống hông.
- **P-IDLE**
```
Pose: standing relaxed idle, feet shoulder-width apart, arms resting naturally at the sides,
looking forward to the right, friendly confident expression.
```
- **O-STRIP(4)**: `1) standing upright, 2) same, 3) body lowered by one pixel as if breathing out, 4) back to upright`.

### `run`
- **Mô tả**: chu kỳ chạy 6 frame, thân hơi đổ về trước. Frame 1 chạm đất chân trước, 2 dồn trọng tâm (thân thấp nhất), 3 đẩy (thân cao nhất, hai chân rời đất), 4–6 lặp lại với chân kia. Tay đánh ngược chân. Đầu nhấp nhô 1 px. Luffy chạy hai tay vung rộng kiểu hồn nhiên; Zoro một tay giữ kiếm.
- **P-RUN**
```
Pose: running fast to the right, body leaning slightly forward, arms swinging opposite to the
legs, energetic.
```
- **O-STRIP(6)**: `1) front foot touching the ground, 2) body at lowest point with weight on front foot, 3) pushing off with both feet off the ground and body at highest point, 4) other foot touching the ground, 5) body at lowest point on the other foot, 6) pushing off again with both feet in the air`.

### `jump_start`
- **Mô tả**: 2 frame: (1) gập gối, thân thấp 2 px, tay kéo ra sau; (2) bật lên, thân duỗi, tay vung lên.
- **P-JUMP-START**
```
Pose: preparing to jump: knees bent deeply, body crouched low, arms swung back behind the
body. Second frame: exploding upward, legs extending, arms swinging up.
```

### `jump_rise`
- **Mô tả**: đang bay lên: thân duỗi thẳng hướng lên trước, một tay giơ cao, chân co một bên. 2 frame khác nhau rất nhẹ (tóc/vạt áo bay).
- **P-JUMP-RISE**
```
Pose: in mid-air rising upward, body stretched, one arm raised high toward the upper right,
one knee pulled up, the other leg trailing, clothes and hair blown downward by the motion.
```

### `jump_apex`
- **Mô tả**: đỉnh cú nhảy, lơ lửng: tay chân dang nhẹ, thân cân bằng.
- **P-JUMP-APEX**
```
Pose: floating at the very top of a jump, body balanced and horizontal-ish, arms and legs
slightly spread, weightless moment.
```

### `fall`
- **Mô tả**: đang rơi: tay giơ lên trên (cân bằng), chân duỗi xuống chuẩn bị đáp, tóc/vạt áo bay lên.
- **P-FALL**
```
Pose: falling downward, arms raised up above the shoulders for balance, legs extended down
ready to land, hair and clothes blown upward.
```

### `land`
- **Mô tả**: (1) chạm đất: gối gập, thân lún 2 px (squash); (2) bật về dáng chạy.
- **P-LAND**
```
Pose: landing on the ground, knees bent to absorb the impact, body squashed down slightly,
arms forward for balance.
```

### `double_jump`
- **Mô tả**: nhảy lần hai trên không — lộn một vòng trước (4 frame: cuộn tròn 90°, 180°, 270°, duỗi ra). Sanji: chân quét vòng có vệt gió.
- **P-DOUBLE-JUMP**
```
Pose: second jump in mid-air, doing a quick forward somersault: frame 1 tucking into a ball,
frame 2 upside down, frame 3 rotating back, frame 4 stretching out upright again.
```

### `hurt`
- **Mô tả**: giật lùi ra sau, mắt nhắm chặt, tay giơ che. Frame 2 trở lại gần dáng chạy.
- **P-HURT**
```
Pose: just got hit from the front, body jerking backward, eyes squeezed shut, arms raised
defensively, surprised pained expression.
```

### `death_hit`
- **Mô tả**: (1) bật ngửa, thân nghiêng 30° ra sau, tay văng; (2) nghiêng 60°, chân rời đất; (3) gần nằm ngang, ngay trước khi chạm đất.
- **P-DEATH-HIT**
```
Pose: knocked backward by a heavy impact: frame 1 body tilting back with arms flung forward,
frame 2 tilted further back with feet leaving the ground, frame 3 almost horizontal in the
air just before hitting the ground on the back.
```

### `death_lie` / `lie_supine`
- **Mô tả**: nằm ngửa trên đất, thân nằm ngang (chiều cao ~8–10 px, rộng ~24 px), tay chân dang, mắt dạng "xx" hoặc xoắn ốc (hài hước kiểu One Piece). Mũ rơi bên cạnh (Luffy).
- **P-LIE-SUPINE**
```
Pose: lying flat on the back on the ground, body horizontal, head to the left and feet to
the right, arms and legs loosely spread, eyes drawn as two small x marks, comedic knocked-out
look.
```

### `lie_prone`
- **Mô tả**: nằm sấp, mặt úp xuống, mông hơi nhô, tay duỗi về trước.
- **P-LIE-PRONE**
```
Pose: lying flat on the stomach face-down on the ground, body horizontal, head to the right,
arms stretched forward, comedic faceplant.
```

### `death_fall`
- **Mô tả**: rơi xuống hố: tay chân quờ quạng, miệng há, 2 frame luân phiên.
- **P-DEATH-FALL**
```
Pose: falling helplessly into a pit, arms and legs flailing wildly, mouth wide open in panic.
```

### `sit` / `sit_idle`
- **Mô tả**: ngồi trên một mép (lan can tàu), hai chân buông thõng; `sit_idle` đung đưa chân, 4 frame.
- **P-SIT**
```
Pose: sitting on the edge of an invisible ledge, legs dangling down, hands resting on the
ledge beside the hips, relaxed happy expression.
```

### `cheer`
- **Mô tả**: ăn mừng: nhảy nhẹ, hai tay giơ lên trời (Luffy), giơ nắm đấm (Zoro), đếm tiền (Nami).
- **P-CHEER**
```
Pose: celebrating a victory, both fists raised high above the head, big open-mouth smile,
small hop off the ground.
```

### `taunt`
- **Mô tả**: dáng đặc trưng: Luffy chỉnh mũ rơm cười; Zoro rút kiếm ngậm kiếm thứ ba; Nami xoè quạt tiền (`nami_money.png`); Usopp giơ ná; Sanji châm thuốc.
- **P-TAUNT** — viết riêng cho từng nhân vật trong khối nhân vật khi cần, ví dụ Luffy:
```
Pose: holding the brim of the straw hat with one hand, grinning widely, confident stance.
```

### `eat`
- **Mô tả**: (1) giơ miếng thịt lên miệng; (2) há to cắn; (3) nhai má phồng.
- **P-EAT**
```
Pose: eating a big cartoon meat on the bone: frame 1 lifting the meat to the mouth, frame 2
mouth wide open biting, frame 3 chewing with puffed cheeks, very happy.
```

### `transform_enter` / `transform_exit`
- **Mô tả chung**: khung 96×96. Thân phồng dần qua 6 frame, có hơi nước/ánh sáng (vẽ trong sprite, không tách VFX), frame cuối là dáng `form_idle`. `transform_exit` ngược lại, xẹp xuống + hơi nước, kết thúc bằng dáng `idle` thường (hơi mệt).
- **Luffy → Gear 4 (Boundman)**: cơ tay to phồng, thân trên đỏ sẫm có hoa văn đen, khói hơi nước từ vai, nảy tại chỗ.
- **P-TRANSFORM-ENTER (Luffy)**
```
Pose sequence on a 96x96 pixel canvas: the boy inflates his muscles into a huge bouncy
muscular form: frame 1 biting his arm, frame 2 body starting to swell with steam puffs,
frame 3 upper body doubled in size, frame 4 arms massive with dark flame-like patterns on
the skin, frame 5 steam bursting from the shoulders, frame 6 final hulking bouncing pose.
Same pixel size as the normal sprite; the character simply becomes bigger.
```

### `form_*` (dạng biến hình)
- **Mô tả**: bộ chạy/nhảy của dạng biến hình. Gear 4 **nảy** thay vì chạy (bật lò xo), `form_attack` = đấm Kong Gun phá vật cản (khung 128×96).
- **P-FORM-RUN (Luffy Gear 4)**
```
Pose: the huge muscular bouncy form moving to the right by bouncing like a spring, frame 1
squashed on the ground, frame 2 stretched in the air, frame 3 at the top, frame 4 coming
down, steam trailing from the shoulders.
```

### `skill_N_*` — ví dụ Luffy Skill 1: Gomu Gomu no Pistol
- **startup** (2 frame): xoay người, kéo tay phải ra sau, nắm đấm siết chặt.
- **active** (2 frame, khung 128×64): tay duỗi dài thành dải (như `luffy_piston_1.png` nhưng hướng phải), nắm đấm ở cuối; frame 2 tay dài nhất có vệt tốc độ.
- **recovery** (2 frame): tay co rút về như dây chun (cong sóng), về tư thế sẵn sàng.
- **Prompt**:
```
Startup: twisting the body and pulling the right fist far back behind the shoulder, fist
clenched, determined face.
Active (128x64 canvas): the right arm stretches like rubber far to the right in a long
straight band of skin color, the fist at the very end, body leaning back; second frame arm
at maximum length with small speed lines.
Recovery: the stretched arm snapping back toward the body in a wavy rubber shape, then
returning to a ready stance.
```

## 5. Prompt hoàn chỉnh — ví dụ để copy (Luffy `idle`)

> Luffy đã có sprite tham chiếu đúng chuẩn nên `idle` dùng thẳng `luffy_normal.png` (xem [prompt library §7](06-prompt-library.md#7-mẹo-theo-model)). Prompt dưới đây là mẫu cho **nhân vật chưa có tham chiếu**; khi dùng, ghép thêm khối P-ANATOMY sau phần "Character".

Đính kèm: `l_z_n_s_u_c.png` (phong cách) + `luffy_normal.png` (nhận diện).

```
Pixel art game sprite in the exact style of the attached reference image: a tiny chibi
character about 24 pixels tall drawn on a 64x64 pixel grid, displayed upscaled 16x so every
pixel is a crisp, perfectly square, equal-sized block aligned to one strict grid. Big head
(about 40% of total height), short body and limbs, simple dark 2-pixel eyes. Flat colors with
2 to 3 shades per material (base, shadow, tiny highlight). No black outline: edges are defined
only by the darker shade of each color. Muted, slightly warm, soft palette, about 12 colors.

Character: a cheerful young pirate boy. Straw hat with a red band (straw colors #E2C397,
#AC906A, band #90191C), short messy black hair (#222124),
open red short-sleeve vest with two yellow buttons (#90191C, shadow #771516), bare chest,
blue denim knee-length shorts with rolled cuffs (#5571A3, #3F5C8B), bare legs, simple
sandals, light skin (#EADAC0, shadow #D0BF9C).

Pose: standing relaxed idle, feet shoulder-width apart, arms resting naturally at the sides,
looking forward to the right, friendly confident expression.

Side view, the character faces RIGHT. One single pose, centered horizontally, feet resting on
an invisible ground line near the bottom of the frame. Plain solid flat background of pure
magenta (#FF00FF) filling the entire image, no ground, no drop shadow, no text, no border,
no other objects. Square 1:1 image.

Do not add black outlines, gradients, anti-aliasing, blur, glow, dithering, noise textures,
3D rendering, vector-smooth curves, motion blur, text, numbers, watermarks, frames or a
background scene. Do not change the proportions or the colors of the character. Do not make
pixels of different sizes.
```

Frame tiếp theo (ví dụ `run` frame 3), đính kèm frame idle đã duyệt (phóng to 16×):
```
Edit the attached sprite. Keep the character, proportions, pixel size, palette, colors and
position of the feet exactly the same. Change ONLY the pose to: running fast to the right,
pushing off the ground with both feet in the air, body leaning forward, arms swinging
opposite to the legs. Keep the plain pure magenta (#FF00FF) background.
```

## 6. Checklist duyệt một bộ animation

- [ ] Khung đúng kích thước (64/96/128), pivot giữa đáy, chân đúng hàng đáy ở mọi frame chạm đất.
- [ ] Không pixel bán trong suốt; không viền đen; màu thuộc bảng con của nhân vật.
- [ ] Silhouette đọc được ở 1×.
- [ ] Tên tag đúng bảng trên, đủ trạng thái B1.
- [ ] `tools/check_sprites.py` pass; chạy thử loop trong Pixelorama: không giật, không rung (lệch pivot).
- [ ] Chiều cao nhân vật nhất quán giữa các frame (trừ squash/stretch có chủ đích).
- [ ] Prompt đã lưu kèm ảnh raw.
