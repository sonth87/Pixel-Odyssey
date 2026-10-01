# Nhân vật và năng lực

## 1. Nhân vật trong game 1 là gì

Trong runner, mọi nhân vật **điều khiển giống hệt nhau** (một nút). Khác biệt chỉ đến từ:

1. **Hình ảnh và âm thanh** (bộ animation, tiếng nhảy, tiếng biến hình).
2. **Nội tại (passive)**: một quy tắc nhỏ thay đổi cách chơi, luôn bật.
3. **Dạng biến hình đặc trưng**: khi ăn item biến hình, mỗi nhân vật biến thành dạng riêng.
4. **Thông số vật lý** có thể chênh lệch rất nhẹ (`ĐỀ XUẤT`: mặc định giống nhau; chỉ chỉnh nếu test thấy cần).

Vì sao không cho mỗi nhân vật nút skill riêng: phá vỡ trụ cột "một nút" (D-001). Các "skill" của nhân vật trong game 1 xuất hiện qua **nội tại** và **biến hình**; ở game 2 các skill đó mới trở thành chiêu chủ động.

## 2. Bảng nhân vật (content pack One Piece)

`ĐỀ XUẤT` — số liệu chỉnh sau test. Cột "Hiệu ứng nguyên tố" là cách nội tại được dựng từ hệ thống hiệu ứng chung ([items](04-items-and-powerups.md)), để không phải code riêng.

| Nhân vật | Nội tại | Hiệu ứng nguyên tố | Dạng biến hình (item biến hình) | MS |
|---|---|---|---|---|
| Luffy | Thời gian mọi năng lực +20% | `duration_mult 1.2` | **Gear 4**: to gấp ~1.5, nảy như lò xo, 8 s | M2 |
| Zoro | Mỗi 12 s tự chém vỡ 1 vật cản mặt đất phía trước (có animation chém) | `auto_destroy(cooldown 12, filter ground)` | **Asura**: bóng 3 đầu 6 tay ở nền, 6 s | M5 |
| Nami | Item xuất hiện nhiều hơn 25%; Berries +20% | `item_spawn_mult 1.25`, `coin_mult 1.2` | **Zeus**: mây sét bay trên đầu đánh xuống mọi thứ phía trước, 8 s | M6 |
| Sanji | Nhảy đôi (lần nhảy thứ hai thấp hơn, ~70%) | `extra_jumps 1, extra_jump_scale 0.7` | **Diable Jambe**: chân lửa, nhảy đôi không giới hạn, 7 s | M6 |
| Usopp | Ngưỡng Perfect Jump rộng gấp 1.5; điểm perfect +20% | `perfect_window_mult 1.5` | **Sogeking**: tự bắn hạ 1 vật cản mỗi 1.5 s, 8 s | M6 |
| Chopper | Bắt đầu run với 1 khiên | `start_shield 1` | **Monster Point**: to lớn, phá mọi vật cản, 6 s | sau M6 |
| Robin | Thấy trước: biểu tượng cảnh báo vật cản sắp tới ở mép phải màn hình | `preview_hazards` | **Gigantesco Mano**: tay khổng lồ đè bẹp vật cản phía trước, 6 s | sau M6 |
| Franky | Điểm combo tăng nhanh hơn 20% | `combo_gain_mult 1.2` | **Franky Shogun / General**: robot, bất tử, 6 s | sau M6 |

Lưu ý cân bằng:
- Nhảy đôi của Sanji rất mạnh với hố → để thứ hai nhảy thấp hơn; theo dõi số liệu playtest.
- Nội tại ảnh hưởng tới bảng xếp hạng: câu hỏi `MỞ` Q-03.

## 3. "Skill" của nhân vật — từ góc độ dữ liệu

Mỗi nhân vật có tối đa **5 skill** trong dữ liệu dùng chung (shared), để game 2 dùng. Game 1 chỉ dùng skill nào được gán vai trò:

| Vai trò trong game 1 | Ví dụ Luffy | Được dùng khi |
|---|---|---|
| `passive_visual` | — | Khi nội tại kích hoạt (Zoro chém) |
| `transform` | Gear 4 | Khi ăn item biến hình |
| `transform_attack` | Gomu Gomu no Kong Gun (khi ở Gear 4) | Khi đang biến hình mà phá một vật cản |
| `pickup_reaction` | Ăn thịt | Khi ăn item |
| (không dùng) | Gomu Gomu no Pistol, Gatling, ... | Chỉ dữ liệu sẵn cho game 2 |

Bảng skill đầy đủ (đề xuất, vẽ dần theo milestone):

| Nhân vật | Skill 1 | Skill 2 | Skill 3 | Skill 4 | Skill 5 |
|---|---|---|---|---|---|
| Luffy | Gomu Gomu no Pistol | Gomu Gomu no Gatling | Gear 2 Jet Pistol | Gear 3 Elephant Gun | Gear 4 Kong Gun |
| Zoro | Oni Giri | Tatsumaki | 36 Pound Ho | Shishi Sonson | Asura |
| Nami | Thunderbolt Tempo | Mirage Tempo | Cyclone Tempo | Thunder Lance | Zeus Breeze |
| Sanji | Collier Shoot | Mouton Shot | Party Table Kick | Concassé | Diable Jambe |
| Usopp | Lead Star | Exploding Star | Firebird Star | Pop Green | Sogeking Shot |

Mỗi skill có animation 3 pha **startup / active / recovery** (D-010) và dữ liệu skill theo [schema](../05-technical/04-data-schemas.md). Đặc tả hình: [character animation spec](../02-art/02-character-animation-spec.md).

## 4. Biến hình — cách hoạt động chung

1. Ăn item biến hình → `pickup_reaction` (0.3 s, không mất điều khiển).
2. Animation `transform_enter` (~0.4 s): **có bất tử** trong lúc này để không chết oan khi đang biến hình.
3. Dạng biến hình: dùng **bộ animation thứ hai** của nhân vật (khung lớn hơn nếu cần), hiệu ứng nguyên tố theo bảng trên.
4. 1.5 s trước khi hết: nhân vật nhấp nháy để cảnh báo.
5. Hết giờ → `transform_exit` (0.3 s, bất tử) → về dạng thường + **0.5 s bất tử sau biến hình** (nhấp nháy). Vì: nếu biến hình hết đúng lúc đang ở trong vật cản → chết oan.
6. **Mọi dạng biến hình phá (hoặc đi xuyên) mọi vật khi chạm** — bất biến E2 ([items §5](04-items-and-powerups.md#5-bất-biến-của-hiệu-ứng)). Vì: hurtbox to hơn không còn chui lọt dưới vật bay dải thấp, nên nếu không bảo vệ toàn bộ sẽ có tình huống không thể tránh. Cái khác nhau giữa các dạng biến hình là **hình ảnh, cảm giác và thời lượng**, không phải mức bảo vệ. Hố vẫn giết (trừ dạng có `rush` hoặc `bridge_gaps`).
7. Dạng biến hình không được làm chậm tốc độ hay giảm lực nhảy (E4).

## 5. Thêm một nhân vật mới

Quy trình từng bước: skill `.claude/skills/add-character/SKILL.md`. Tóm tắt:
1. Thiết kế: nội tại (dựng từ hiệu ứng nguyên tố có sẵn), dạng biến hình, 5 skill, bảng màu.
2. Art: gen + xử lý theo [pipeline](../02-art/05-ai-image-pipeline.md), đủ bộ animation bắt buộc.
3. Dữ liệu: tạo `CharacterData` + `AnimationSet` + `SkillData` trong content pack.
4. Âm thanh, chữ (tên, mô tả nội tại).
5. Kiểm tra: test bộ animation đủ trạng thái, chạy thử với debug.
Nếu nội tại cần một hiệu ứng nguyên tố **chưa có** → đó là thay đổi code (thêm hiệu ứng mới vào hệ thống chung), làm riêng và review riêng.
