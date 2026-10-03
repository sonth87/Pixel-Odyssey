# Roadmap, kế hoạch công việc, checklist

File này là **bảng theo dõi tiến độ**. Mục tiêu và tiêu chí hoàn thành của từng milestone ở [milestones](03-milestones.md); file này chia milestone thành **việc cụ thể**, ai làm, phụ thuộc gì, và checklist.

Cách dùng:
- Đánh dấu `[x]` khi xong. Việc đang làm ghi `[~]`.
- Milestone đang làm và milestone kế tiếp được chia việc chi tiết; các milestone xa hơn chỉ có việc chính — **chia chi tiết khi milestone trước đóng lại**, dựa trên số liệu thật. Vì: kế hoạch chi tiết cho việc 3 tháng sau gần như chắc chắn sai.
- Ai làm: **Bạn** (chủ dự án), **Claude**, **Cả hai** (Claude chuẩn bị, bạn thực hiện/duyệt).

---

## 1. Roadmap

```
         ┌─────────────── Track CODE ───────────────┐
M0 ──► [Tài liệu input/hiển thị/tất định] ──► M1 ──► M2 ──► M3 ──► M4 ──► M5 ──► M6 ──► M7 ──► M8
 │                                            ▲      ▲      ▲
 └── Track ART: quy trình ảnh ──► art Luffy ──┘      │      │
                       └──► art Alabasta (bắt đầu song song từ giữa M2) ──┘
     Track AUDIO: SFX tạm (M1) ──► SFX Luffy (M2) ──► nhạc + ambience Alabasta (M3)
```

| Giai đoạn | Milestone | Kết quả chơi được | Cổng kiểm tra trước khi qua |
|---|---|---|---|
| Nền móng | M0 | — (quy trình art chạy thông) | Luffy idle hiện pixel-perfect trong Godot |
| Cảm giác chơi | M1 | Khối xám chạy, nhảy, đạp, chết, chơi lại | Playtest: ≥ 1/2 người tự chơi lại; validator xanh |
| Nhân vật đầu | M2 | Luffy đầy đủ + item | Đo được giờ làm 1 nhân vật |
| Đảo đầu | M3 | Alabasta trọn vẹn | 60 FPS máy thật; đo được giờ làm 1 đảo |
| Game hoàn chỉnh | M4 | Menu, điểm, lưu, ngôn ngữ | Người lạ chơi được không cần hướng dẫn |
| Mở rộng | M5 | Zoro + pack thử | Thêm Zoro không sửa code gameplay |
| Nội dung | M6 | 6 đảo phát hành | Run tốt ≥ 10 phút |
| Giữ chân | M7 | Berries, bảng xếp hạng, thử thách ngày | Phát lại run trên server khớp |
| Phát hành | M8 | Android/iOS | QA đạt |

**Đường găng** (việc trễ là cả dự án trễ): quy trình art (M0) → cảm giác chơi (M1) → Luffy (M2) → Alabasta (M3). Art Alabasta là khối lượng lớn nhất → bắt đầu song song từ giữa M2.

---

## 2. M0 — Nền móng (đang làm)

| ID | Việc | Ai | Phụ thuộc | Xong khi |
|---|---|---|---|---|
| [x] M0-01 | Khởi tạo git, Git LFS, `.gitignore`, `.gitattributes`, commit đầu (tài liệu hiện có) | Claude | — | `git log` có commit; ảnh đi qua LFS |
| [x] M0-02 | Cài Godot 4 bản stable mới nhất; báo số phiên bản | Bạn | — | Mở được Godot |
| [x] M0-03 | Ghi phiên bản Godot vào decision log | Claude | M0-02 | Có mục D-xxx |
| [x] M0-04 | Tạo project Godot trong `game/`, cây thư mục theo [project structure](../05-technical/02-project-structure.md), cấu hình hiển thị pixel-perfect theo [tooling §3](../05-technical/06-tooling-and-workflow.md#3-cấu-hình-project-godot-m0) | Claude | M0-02 | Scene trống chạy ở 320×180, phóng to sắc nét |
| [x] M0-05 | Cài plugin test gdUnit4, 1 test mẫu chạy được bằng dòng lệnh | Claude | M0-04 | Lệnh test headless pass |
| [x] M0-06 | Ảnh tham khảo chuyển sang `assets/` (bạn đã làm); cập nhật đường dẫn trong tài liệu | Cả hai | — | Không còn link tới đường dẫn cũ |
| [x] M0-07 | `tools/extract_palette.py` → `art-source/palettes/master.gpl` + bảng con cho 8 nhân vật | Claude | M0-06 | File .gpl mở được trong Aseprite |
| [x] M0-08 | `tools/pixelize.py` theo [pipeline §5](../02-art/05-ai-image-pipeline.md) + chạy thử trên **toàn bộ** ảnh tham khảo | Claude | M0-07 | Ảnh tham khảo → 64×64 đúng lưới, báo cáo lưới dò được |
| [x] M0-09 | Cài Pixelorama (miễn phí) | Bạn | — | Mở được, nhập được bảng màu `.gpl` |
| [x] M0-10 | Gen ảnh Luffy `idle` bằng Gemini theo prompt soạn sẵn; lưu raw + `.prompt.md` | Cả hai | — | Có ảnh raw được chọn |
| [x] M0-11 | Frame Luffy `idle` (từ ảnh tham chiếu, nhịp thở) + nháp `run` 6 frame vẽ bằng code; `.pxo` chỉ tạo khi cần sửa tay | Claude | M0-08 | `check_sprites.py` pass; render trong Godot đúng vị trí |
| [x] M0-12 | Định dạng dải PNG mỗi animation (D-029) + `tools/check_sprites.py`; xuất `idle.png` vào `game/content/onepiece/characters/luffy/sprites/base/` | Cả hai | M0-11 | `check_sprites.py` pass |
| [x] M0-13 | Scene thử hiển thị Luffy `idle` đúng pivot, pixel-perfect | Claude | M0-04, M0-12 | Chụp màn hình 4×: pixel vuông, chân đúng mặt đất |
| [x] M0-14 | Viết tài liệu **input / hiển thị / tất định** (`05-technical/08-input-rendering-determinism.md`): đơn vị số nguyên, nhận chạm theo tick, nội suy hình, cuộn pixel, tỉ lệ màn hình | Claude | — | Bạn duyệt; các thông số physics quy đổi sang nguyên |
| [x] M0-15 | Đóng M0: cập nhật tài liệu theo thực tế (thời gian làm 1 frame, lỗi của pixelize), chia việc chi tiết M2 | Claude | tất cả | Checklist mục 10 |

Có thể làm song song: M0-01/04/05/06/07/08/14 (Claude) cùng lúc với M0-02/09/10 (Bạn).

---

## 3. M1 — Cảm giác chơi (greybox)

Điều kiện bắt đầu: M0 đóng, tài liệu input/hiển thị/tất định (M0-14) đã duyệt.

| ID | Việc | Ai | Phụ thuộc | Xong khi |
|---|---|---|---|---|
| [x] M1-01 | Thư viện số nguyên cố định (`shared/core/math/`) + `RunnerPhysicsConfig` | Claude | M0-14 | Test: bảng nhảy trong [physics §2](../05-technical/05-physics-collision-generation.md#2-nhảy) khớp ±1 px |
| [x] M1-02 | `RngStreams` (4 luồng từ 1 seed) | Claude | — | Test tất định: cùng seed → cùng chuỗi |
| [x] M1-03 | Xử lý input: chạm xuống = nhảy, giữ, jump buffer, coyote; ghi/phát lại input | Claude | M1-01 | Test buffer/coyote; phát lại run cho cùng kết quả |
| [x] M1-04 | `RunnerBody`, `JumpController`, state machine (Running/Airborne/Dead) | Claude | M1-01, M1-03 | Nhảy chạm/giữ đúng độ cao |
| [x] M1-05 | Địa hình: mặt đất, hố, bậc, tự bước lên, corner correction, `WALL`, `PIT` | Claude | M1-04 | Test corner correction 6/7 px |
| [x] M1-06 | `Obstacle` + `StaticBehavior` + `ChargerBehavior` + hitbox/hurtbox | Claude | M1-04 | Kẻ địch lao tới kích hoạt theo vị trí |
| [~] M1-07 | `CollisionResolver`: thường, khiên (qua debug), i-frames, đạp | Claude | M1-05, M1-06 | Test các ô tương ứng của ma trận |
| [x] M1-08 | Định dạng chunk (`ChunkDefinition`, slot) + 12–15 chunk greybox | Claude | M1-05, M1-06 | Chunk mở được trong editor |
| [x] M1-09 | `ObjectPool`, `ChunkSpawner`, `StageDirector` (1 đảo greybox, tốc độ đầu → cuối) | Claude | M1-08, M1-02 | Chạy liên tục 10 phút không lỗi |
| [x] M1-10 | Validator (vật tĩnh + kẻ địch lao tới, cửa sổ thời điểm, luật thời gian phản ứng) + chạy headless | Claude | M1-08 | Mọi chunk xanh; chunk mẫu sai bị báo lỗi |
| [x] M1-11 | `RunController`/`RunContext`; chết → Game Over → chơi lại ≤ 1 s | Claude | M1-09 | Đo thời gian chơi lại |
| [x] M1-12 | HUD quãng đường; camera theo độ cao mặt đất | Claude | M1-09 | |
| [~] M1-13 | Chế độ debug (F1 overlay, F3 bất tử, F4 slow-mo, R restart) + log vị trí chết | Claude | M1-11 | F2 (hitbox), F5 (đoạn kế), F6 (nhập seed), F7 (item) chưa có ý nghĩa tới khi có sprite/nhiều đoạn/item (M2-M3); F8/F9 (ghi/phát lại) có sẵn trong `RunSimulation` nhưng chưa gắn phím; log chết ra CSV chưa làm |
| [x] M1-14 | `check_layers.py`, `check_ip_names.py` | Claude | M0-04 | Chạy được, đang pass |
| [ ] M1-15 | 3 SFX tạm (nhảy, đáp, chết) bằng jsfxr | Cả hai | — | |
| [ ] M1-16 | Xuất bản PC/Android để playtest | Claude | M1-11 | Cài được lên máy bạn |
| [ ] M1-17 | Playtest 3–5 người × 5 phút; ghi nhận xét + log chết | Bạn | M1-16 | Có bảng ghi chép — hoãn, xem D-036 |
| [ ] M1-18 | Chỉnh thông số theo playtest; cập nhật physics + decision log; chạy lại validator | Cả hai | M1-17 | Tiêu chí M1 trong milestones đạt |

Song song phía Bạn trong M1: gen + sửa các frame B1 của Luffy (chuẩn bị M2) — xem M2-01.

---

## 4. M2 — Luffy hoàn chỉnh

| ID | Việc | Ai | Phụ thuộc |
|---|---|---|---|
| [ ] M2-01 | Art Luffy B1 (`run` đã có nháp — tinh chỉnh): `jump_start`, `jump_rise`, `jump_apex`, `fall`, `land`, `hurt`, `death_hit`, `death_lie`, `death_fall`, `eat` (Claude soạn prompt từng tag, bạn gen + sửa) | Cả hai | M0 |
| [ ] M2-02 | Art Gear 4 (khung 96): `transform_enter/exit`, `form_idle/run/jump_rise/fall/land/attack` | Cả hai | M2-01 |
| [ ] M2-03 | `CharacterData`, `CharacterFormData`, `AnimationSet`, `SkillData`, `RunnerCharacterProfile` + dữ liệu Luffy | Claude | M1 |
| [ ] M2-04 | `CharacterView` chọn animation theo trạng thái; FPS chạy co giãn theo tốc độ | Claude | M2-03 |
| [ ] M2-05 | `EffectHost` + các lớp hiệu ứng cần cho M2 + quy tắc chồng + kiểm tra bất biến E1–E4 | Claude | M1 |
| [ ] M2-06 | Ma trận tương tác đầy đủ (biến hình, phá, xuyên) + test | Claude | M2-05 |
| [ ] M2-07 | Item: xu, túi xu, khiên, thịt; `ItemSpawner` theo luật sinh | Claude | M2-05 |
| [ ] M2-08 | Art item + VFX cơ bản (bụi, lấp lánh, bong bóng, vỡ khiên, biến hình, phá vật) | Cả hai | — |
| [ ] M2-09 | `AudioService` + bus; SFX Luffy và item | Cả hai | — |
| [ ] M2-10 | Test bộ animation đủ trạng thái bắt buộc | Claude | M2-03 |
| [ ] M2-11 | Đóng M2: ghi số giờ thật cho 1 nhân vật; chia việc chi tiết M3 | Cả hai | tất cả |

Từ giữa M2: bắt đầu art Alabasta (nền đoạn 1–2, chướng ngại vật) — khối lượng lớn nhất của M3.

## 5. M3 — Vertical slice Alabasta (việc chính)

- [ ] Hành vi còn lại: tuần tra, nhảy lên, bay, bắn, rơi, quét — kèm validator mô phỏng được.
- [ ] Art: 5 đoạn × lớp parallax + mảnh chuyển tiếp + tileset + chướng ngại vật + kẻ địch + NPC + sự kiện + tàu Going Merry.
- [ ] `ParallaxController`, `DecorationSpawner`, NPC 3 hạng, `EventDirector` (Crocodile, lưỡi cát, bom tháp đồng hồ).
- [ ] 15–25 chunk mỗi đoạn (ưu tiên chunk dùng chung), validator xanh.
- [ ] Đoạn biển + lối ra/lối vào đảo.
- [ ] Nhạc Alabasta (2 stem), nhạc biển, ambience 5 đoạn.
- [ ] Đo FPS trên Android tầm trung.
- [ ] Đóng M3: ghi số giờ thật cho 1 đảo → cập nhật ngân sách sản xuất, xem lại Q-06.

## 6. M4 — Vòng lặp game hoàn chỉnh (việc chính)
- [ ] Tài liệu đặc tả màn hình (wireframe) + chốt D-017.
- [ ] Các màn: khởi động, menu, pause, kết quả, cài đặt.
- [ ] Điểm, combo, Perfect (theo định nghĩa chính xác).
- [ ] Lưu có phiên bản; đa ngôn ngữ vi/en; font tiếng Việt.
- [ ] Hướng dẫn lồng trong run đầu; pause tự động.

## 7. M5–M8 (việc chính)
- **M5**: Zoro qua skill `add-character` không sửa code gameplay; màn chọn nhân vật; content pack thử nghiệm `original`.
- **M6**: 5 đảo còn lại của hành trình phát hành; vòng lặp; trái ác quỷ; đủ 5 nhân vật; chốt Q-06.
- **M7**: Berries, nâng cấp, mở khoá; bảng xếp hạng + phát lại trên server; thử thách hằng ngày; analytics; chốt Q-02, Q-03, Q-04, Q-07.
- **M8**: tối ưu; xuất bản Android/iOS; ảnh store; QA; quyền riêng tư.

---

## 8. Nhịp làm việc

**Mỗi phiên làm việc**
1. Xem milestone đang làm trong file này, chọn việc chưa xong có đủ phụ thuộc.
2. Làm; chạy test + validator + script kiểm tra.
3. Đánh dấu tiến độ ở file này; ghi quyết định mới (skill `record-decision`).

**Mỗi tuần**
- Bạn chơi bản mới nhất ít nhất 10 phút, ghi cảm nhận.
- Rà các việc bị kẹt; điều chỉnh thứ tự.

---

## 9. Checklist theo loại công việc ("xong" nghĩa là gì)

### 9.1 Code
- [ ] Đúng tài liệu liên quan; nếu khác tài liệu → đã cập nhật tài liệu + decision log.
- [ ] Kiểu tĩnh đầy đủ; file ≤ 300 dòng, hàm ≤ 50 dòng.
- [ ] Không comment lịch sử, không code chết, không chuỗi hiển thị trong code.
- [ ] Không `float` trong mô phỏng gameplay; không RNG toàn cục trong `runner/`.
- [ ] Test liên quan có và pass; `check_layers.py`, `check_ip_names.py` pass.
- [ ] Chạy thử trong game, không cảnh báo mới.

### 9.2 Sprite / art
- [ ] Prompt lưu cạnh ảnh raw.
- [ ] Khung đúng kích thước; pivot giữa đáy; chân đúng hàng đáy.
- [ ] Alpha chỉ 0/255; không viền đen; màu trong bảng con.
- [ ] Đọc được ở 1× trên mọi nền nó xuất hiện.
- [ ] Tag đúng tên chuẩn; loop không rung.
- Chi tiết: [animation spec §6](../02-art/02-character-animation-spec.md#6-checklist-duyệt-một-bộ-animation), [obstacles spec §7](../02-art/04-obstacles-items-vfx-ui-spec.md#7-checklist-duyệt).

### 9.3 Chunk
- [ ] Vùng đệm 48 px hai đầu; entry/exit height khớp.
- [ ] Slot đặt theo loại (ưu tiên) và trong giới hạn kích thước.
- [ ] Validator xanh (cửa sổ ≥ 4 tick, thời gian phản ứng ≥ 0.70 s).
- [ ] Chơi thử bằng debug ở tốc độ min và max.

### 9.4 Âm thanh
- [ ] Prompt/tham số sfxr lưu cạnh file gốc.
- [ ] Đúng định dạng, đúng bus; loop liền mạch; không vỡ tiếng khi chồng.
- [ ] Có tín hiệu hình tương ứng cho âm cảnh báo.

### 9.5 Tài liệu
- [ ] Mô tả trạng thái hiện tại (không "đã đổi từ...").
- [ ] Mỗi thông tin một nguồn; nơi khác chỉ link.
- [ ] Quyết định mới có mục trong decision log.
- [ ] Link/anchor kiểm tra không lỗi.

## 10. Checklist đóng milestone
- [ ] Mọi tiêu chí hoàn thành trong [milestones](03-milestones.md) đạt.
- [ ] Mọi việc trong file này của milestone đã `[x]` hoặc chuyển sang milestone sau có ghi lý do.
- [ ] Không còn `TODO(M<n>)` trong code.
- [ ] Tài liệu cập nhật theo thực tế (thông số đã chỉnh, thời gian thật).
- [ ] Milestone kế tiếp đã được chia việc chi tiết trong file này.
- [ ] Commit/tag `m<n>-done`.
