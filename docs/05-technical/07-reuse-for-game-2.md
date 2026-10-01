# Tái sử dụng cho game 2 (kiểu Ninja School)

## 1. Game 2 là gì (tại thời điểm viết)

Cùng thế giới, nhân vật, art với game 1; lối chơi hành động: di chuyển tự do, đánh nhau, skill chủ động, damage, crit, chỉ số... Chưa có tài liệu thiết kế riêng. File này chỉ quy định **những gì game 1 phải làm ngay bây giờ** để game 2 dùng lại được, và **những gì không chia sẻ**.

## 2. Chia sẻ / không chia sẻ

| Thành phần | Chia sẻ? | Vì sao |
|---|---|---|
| Art nhân vật (sprite, animation theo tên chuẩn) | **Có** | Tốn công nhất; đã vẽ theo chuẩn có cả trạng thái G2 |
| `CharacterData`, `CharacterFormData`, `AnimationSet`, `SkillData` | **Có** | Mô tả nhân vật, không phụ thuộc lối chơi |
| Danh sách tên animation chuẩn | **Có** | Code cả hai game gọi cùng tên |
| Âm thanh nhân vật, âm UI | **Có** | |
| File ngôn ngữ phần nhân vật/thế giới | **Có** | |
| Art nền, chướng ngại vật | Một phần | Nền parallax dùng được cho cảnh nền game 2; chướng ngại vật runner thì không |
| EventBus, StateMachine, RngStreams, Save, Settings, Audio, ObjectPool | **Có** | Tiện ích không phụ thuộc lối chơi |
| Theme UI, font, thành phần UI | **Có** | Đồng bộ thương hiệu |
| Vật lý nhảy, chunk, validator, combo, perfect jump | **Không** | Đặc thù runner |
| EffectHost và hiệu ứng runner | **Không** | Game 2 cần hệ buff/debuff có chỉ số — thiết kế riêng, có thể học ý tưởng |
| `RunnerCharacterProfile` | **Không** | Là "góc nhìn runner" của nhân vật; game 2 sẽ có `ActionCharacterProfile` riêng trỏ tới cùng `CharacterData` |

Vì sao không chia sẻ gameplay: hai lối chơi khác bản chất; ép một "engine chung" sẽ phải đầy cờ `if game == runner` — tệ cho cả hai (D-007).

## 3. Việc game 1 phải làm ngay

1. **Giữ `shared/` sạch**: không tham chiếu runner/app/content (kiểm tra tự động).
2. **Vẽ animation theo bảng chuẩn**, kể cả chia pha startup/active/recovery cho skill (D-010). Trạng thái G2 không cần vẽ bây giờ, nhưng tên đã chốt.
3. **`SkillData` có `magnitude` và `tags`** — đủ để game 2 diễn giải; không thêm trường damage/crit/mana bây giờ (sẽ thêm khi game 2 có thiết kế thật, Resource mở rộng dễ dàng).
4. **Mỗi nhân vật lưu nguồn art đầy đủ** trong `art-source/aseprite/` (không chỉ bản xuất) để game 2 xuất lại theo nhu cầu.
5. **Tên trung lập** trong code dùng chung.

## 4. Khi bắt đầu game 2

1. Tách `game/shared/` thành repo riêng (ví dụ `pixel-shared`), dùng trong cả hai game qua **git submodule** hoặc như một addon Godot (`addons/pixel_shared/`).
2. Đánh phiên bản cho shared (`v1.0.0`...); game 1 khoá phiên bản đang dùng.
3. Content pack tách thành hai phần: phần chung (nhân vật, art, âm) và phần riêng mỗi game (đảo runner / bản đồ game 2).
4. Viết tài liệu thiết kế game 2 trong repo của nó; file này chuyển thành tài liệu của repo shared.

## 5. Rủi ro

| Rủi ro | Phòng tránh |
|---|---|
| `shared` dần chứa thứ chỉ runner cần | Câu hỏi khi thêm: "game hành động có cần cái này không?" Không → để trong `runner/` |
| Khung 64×64 không đủ cho đòn đánh game 2 | Đã có khung rộng/lớn; game 2 có thể dùng camera gần hơn nhưng giữ mật độ pixel |
| Game 2 cần nhìn nhiều hướng (trên/dưới) | Ghi nhận: art hiện tại chỉ có góc nghiêng. Nếu game 2 cần 4 hướng → phải vẽ thêm; quyết định khi thiết kế game 2 |
