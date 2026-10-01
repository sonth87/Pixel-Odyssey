# Milestone

## Nguyên tắc chia milestone

1. **Mỗi milestone kết thúc bằng một bản chơi được** (trừ M0). Không có milestone "chỉ viết engine".
2. **Làm trọn một thứ trước khi nhân bản**: 1 nhân vật trọn vẹn trước khi làm nhân vật thứ 2; 1 đảo trọn vẹn trước khi làm đảo thứ 2. Vì: chỉ khi làm trọn một lần mới biết chi phí thật và lỗi của quy trình.
3. **Hình khối xám trước, art đẹp sau** (greybox): cảm giác nhảy phải "đã" với hình chữ nhật xám trước khi bỏ công vẽ. Art đẹp không cứu được gameplay dở.
4. Mỗi milestone có **tiêu chí hoàn thành đo được**. Chưa đạt → chưa sang milestone sau (có thể làm song song art cho milestone sau).
5. Milestone ghi **ngoài phạm vi** để chống phình to không kiểm soát trong từng giai đoạn — phạm vi tổng vẫn lớn, nhưng được xếp vào đúng chỗ.

Thời gian ước lượng giả định 1 người làm bán thời gian; dùng để so sánh tương đối, không phải cam kết.

## Tổng quan

| MS | Tên | Kết quả chơi được | Ước lượng |
|---|---|---|---|
| M0 | Nền móng | (Chưa chơi) Repo, tài liệu, project Godot, quy trình art chạy thông với 1 sprite | 1–2 tuần |
| M1 | Cảm giác chơi (greybox) | Khối xám chạy, nhảy, chết, chơi lại; chunk ngẫu nhiên có kiểm soát | 2–3 tuần |
| M2 | Luffy hoàn chỉnh | Luffy đầy đủ animation, khiên bong bóng, biến hình Gear 4, âm thanh cơ bản | 3–4 tuần |
| M3 | Vertical slice Alabasta | Chạy trọn Alabasta 5 đoạn + parallax + NPC + sự kiện Crocodile + lên tàu Going Merry | 5–8 tuần |
| M4 | Vòng lặp game hoàn chỉnh | Menu, kết quả, kỷ lục, cài đặt, đa ngôn ngữ, combo/perfect, pause, lưu | 3–4 tuần |
| M5 | Chứng minh khả năng mở rộng | Zoro thêm vào chỉ bằng dữ liệu; đổi content pack thử nghiệm không sửa code | 3–4 tuần |
| M6 | Mở rộng hành trình | Thêm đảo, đoạn biển đa dạng, hệ trái ác quỷ, đủ 5 nhân vật | 8–12 tuần |
| M7 | Meta & cạnh tranh | Berries, nâng cấp, mở khoá, bảng xếp hạng, thử thách hằng ngày | 4–6 tuần |
| M8 | Hoàn thiện & phát hành | Tối ưu, xuất bản Android/iOS | 4–6 tuần |

---

## M0 — Nền móng

**Mục tiêu**: mọi thứ cần để bắt đầu làm việc đúng cách đã sẵn sàng; quy trình art đã được chứng minh với 1 ảnh thật.

**Phạm vi**
- Khởi tạo git + Git LFS (cho ảnh, âm thanh, file .pxo). `.gitignore` cho Godot.
- Bộ tài liệu này (đã có) + `CLAUDE.md` + skill quy trình trong `.claude/skills/`.
- Project Godot trong thư mục `game/` với cấu trúc thư mục theo [project structure](../05-technical/02-project-structure.md), cấu hình hiển thị pixel-perfect (độ phân giải logic, phóng to số nguyên, lọc Nearest).
- Khoá phiên bản Godot, ghi vào decision log.
- Script `tools/pixelize.py`: ảnh AI → pixel art thật; `tools/check_sprites.py` kiểm tra dải PNG (tìm lưới, thu nhỏ, xoá nền, ép bảng màu, đặt vào khung chuẩn). Đặc tả ở [AI image pipeline](../02-art/05-ai-image-pipeline.md).
- File bảng màu chuẩn (`art-source/palettes/master.gpl`) trích từ ảnh nhân vật hiện có.
- Chạy thử toàn bộ quy trình art với **1 ảnh**: `luffy idle` → gen → pixelize → Pixelorama → Godot → hiện trên màn hình.
- Ảnh tham khảo đặt ở `assets/` (`assets/charactors/`, `assets/1–3.jpg`).

**Tiêu chí hoàn thành**
- [ ] `git log` có commit đầu; file ảnh lớn đi qua LFS.
- [ ] Mở project Godot, chạy được scene trống ở độ phân giải logic, phóng to cửa sổ thấy pixel vuông sắc nét.
- [ ] Luffy idle (ít nhất 1 frame) đi trọn quy trình và hiện đúng kích thước, đúng tâm (pivot) trong Godot.
- [ ] `tools/pixelize.py` có hướng dẫn chạy, xử lý được toàn bộ ảnh trong thư mục tham khảo.

**Ngoài phạm vi**: gameplay, UI, âm thanh.

**Rủi ro**: AI gen không ra đúng lưới pixel → script phải xử lý được ảnh "pixel giả"; nếu không, chấp nhận vẽ lại tay trong Pixelorama (nhân vật chỉ ~14×24 px nên vẽ tay vẫn nhanh).

---

## M1 — Cảm giác chơi (greybox)

**Mục tiêu**: chứng minh "nhảy né có đã tay không" chỉ bằng hình khối.

**Phạm vi**
- Nhân vật là hình chữ nhật; chạy tự động, nhảy (chạm/giữ), coyote time, jump buffer, trọng lực, đáp đất.
- Tốc độ tăng theo quãng đường.
- 3 loại chướng ngại vật khối: thấp (nhảy chạm), cao (phải giữ), hố; bậc địa hình.
- 1 kẻ địch khối đạp được với hành vi `CHARGER` (kích hoạt theo vị trí, có báo trước).
- Luật tương tác cơ bản: chết `CONTACT`/`PIT`/`WALL`, khiên, i-frames, đạp, corner correction — có test theo ma trận.
- Hệ thống **chunk**: 10–15 chunk greybox, chọn ngẫu nhiên có trọng số theo độ khó, RNG có seed.
- **Validator** kiểm tra mọi chunk vượt qua được ở mọi tốc độ trong khoảng cho phép.
- Chết → màn "Game Over" tối giản → chạm chơi lại.
- HUD: quãng đường (m).
- Chế độ debug: hiện hitbox, chỉnh tốc độ, bất tử, nhập seed, hiện tên chunk hiện tại.
- Test tự động: tất định theo seed, validator.

**Tiêu chí hoàn thành**
- [ ] Đạt FR-GP-01..07, FR-WD-03, FR-WD-04, FR-SC-01, NFR-DT-01, NFR-QA-01.
- [ ] Cho 3–5 người chơi thử 5 phút: có ít nhất một nửa tự bấm chơi lại mà không cần nhắc.
- [ ] Bảng thông số vật lý đã chỉnh sau test được cập nhật vào [physics](../05-technical/05-physics-collision-generation.md).

**Ngoài phạm vi**: art thật, item, parallax, âm thanh (có thể dùng 2–3 tiếng bíp tạm).

---

## M2 — Luffy hoàn chỉnh

**Mục tiêu**: một nhân vật trọn vẹn đi hết quy trình art → animation → dữ liệu → gameplay; qua đó đo chi phí một nhân vật.

**Phạm vi**
- Toàn bộ animation **bắt buộc cho runner** của Luffy theo [character animation spec](../02-art/02-character-animation-spec.md) (idle, run, jump_start, jump_rise, jump_apex, fall, land, hurt, death_hit, death_lie, cheer...).
- Dạng biến hình Gear 4 (animation riêng, khung lớn hơn) + item biến hình (thịt).
- Item khiên (bong bóng) — kiểu "theo số lần".
- Item điểm (Berry xu) — kiểu "tức thì".
- Hệ thống hiệu ứng nguyên tố (EffectHost) + quy tắc chồng hiệu ứng + kiểm tra bất biến E1–E4 khi nạp.
- Ma trận tương tác đầy đủ (biến hình, phá, xuyên) có test.
- Dữ liệu nhân vật Luffy bằng Resource, bộ animation chuẩn hoá.
- VFX cơ bản: bụi khi đáp, tia khi ăn item, vỡ khiên.
- SFX cơ bản: nhảy, đáp, ăn item, vỡ khiên, chết.
- Kiểm tra tự động: bộ animation đủ trạng thái bắt buộc.

**Tiêu chí hoàn thành**
- [ ] Đạt FR-CH-02, FR-CH-04 (Luffy), FR-IT-01, FR-IT-02, FR-IT-03, FR-IT-05, FR-AU-02.
- [ ] Ghi lại **số giờ thực tế** để làm xong Luffy (art + tích hợp) vào decision log → dùng ước lượng nhân vật sau.
- [ ] Không có chữ "luffy" trong code gameplay (`game/runner/`, `game/shared/`).

**Ngoài phạm vi**: nền đẹp (vẫn dùng nền đơn sắc + mặt đất tạm), nhân vật khác.

---

## M3 — Vertical slice Alabasta

**Mục tiêu**: một đảo hoàn chỉnh như thành phẩm. Sau M3 phải biết **công thức sản xuất một đảo**; các đảo sau chủ yếu là thay asset + dữ liệu.

**Phạm vi**
- Đặc tả đầy đủ ở [Alabasta](../01-game-design/07-island-alabasta.md).
- 5 đoạn: Sa mạc → Rainbase → Yuba → Sa mạc & sông Sandora → Alubarna.
- Parallax 5–6 lớp mỗi đoạn + mảnh chuyển tiếp giữa các đoạn.
- Địa hình bậc (FR-GP-08), chướng ngại vật trên không (FR-GP-09).
- Bộ chướng ngại vật/kẻ địch Alabasta với đủ các hành vi (tuần tra, nhảy lên, bay, bắn, rơi, quét), 15–25 chunk mỗi đoạn (ưu tiên chunk dùng chung trong `content/common/`).
- NPC ba hạng (ambient, reactive, set-piece).
- NPC nền với mật độ theo đoạn.
- Sự kiện Crocodile (nền) + chuỗi "lưỡi cát" (chướng ngại vật đặc biệt).
- Đoạn chuyển sang biển: nhảy lên Going Merry, đoạn biển 20–30 giây, cập đảo tiếp theo (đảo tiếp theo là placeholder).
- Nhạc Alabasta + nhạc biển + ambience từng đoạn.
- Object pool, đo FPS trên điện thoại thật.

**Tiêu chí hoàn thành**
- [ ] Đạt FR-WD-01..09, FR-GP-08, FR-GP-09, FR-AU-01, NFR-PF-02, NFR-AC-02.
- [ ] Chạy trọn Alabasta (≈3–4 phút) không lỗi hình, không chết oan (validator + playtest).
- [ ] 60 FPS trên 1 máy Android tầm trung.
- [ ] Viết lại skill `add-island` theo những gì học được (thứ tự bước thật sự, thời gian thật).

**Ngoài phạm vi**: các đảo khác, menu hoàn chỉnh.

---

## M4 — Vòng lặp game hoàn chỉnh

**Mục tiêu**: một bản có thể đưa người khác chơi như một game thật.

**Phạm vi**
- Màn hình: khởi động, menu chính, chạy, pause, kết quả (quãng đường, điểm, kỷ lục, đảo xa nhất), cài đặt.
- Điểm số + combo + Perfect Jump.
- Lưu: kỷ lục, cài đặt, đảo xa nhất; có phiên bản dữ liệu lưu.
- Đa ngôn ngữ vi/en, font pixel có đủ dấu tiếng Việt.
- Cài đặt: nhạc, hiệu ứng, ngôn ngữ, rung, rung màn hình, giảm nhấp nháy.
- Hướng dẫn lồng trong run đầu.
- Pause tự động khi app chạy nền.

**Tiêu chí hoàn thành**
- [ ] Đạt FR-GP-06 (≤1 giây), FR-GP-10, FR-GP-11, FR-SC-02..04, FR-UI-01..03, FR-LC-01, FR-LC-02, FR-AU-03, NFR-AC-01, NFR-OF-01, NFR-SV-01.
- [ ] Một người chưa từng thấy game chơi được mà không cần giải thích.

---

## M5 — Chứng minh khả năng mở rộng

**Mục tiêu**: chứng minh kiến trúc content pack hoạt động — nếu không chứng minh sớm, đến lúc cần thì đã quá muộn.

**Phạm vi**
- Thêm **Zoro** theo đúng skill `add-character`, **không sửa code gameplay**. Nội tại + dạng biến hình của Zoro.
- Màn chọn nhân vật.
- Tạo content pack thử nghiệm `original` tối giản: 1 nhân vật tự thiết kế (tạm), 1 đảo dùng lại chunk Alabasta với asset khác (có thể đổi màu), 3 item tên khác.
- Cài đặt (ẩn trong bản dev) để đổi pack.

**Tiêu chí hoàn thành**
- [ ] Đạt FR-CH-01, FR-CH-03, FR-CH-05, FR-LC-03, NFR-EX-01, NFR-EX-02.
- [ ] `git diff` của việc thêm Zoro không chạm vào `game/runner/` và `game/shared/`.

---

## M6 — Mở rộng hành trình

**Phạm vi**
- Hoàn thiện thứ tự hành trình đầu game (các đảo East Blue rút gọn trước Alabasta) — xem [hành trình](../01-game-design/02-run-journey-and-stages.md).
- Thêm 2–3 đảo sau Alabasta (đề xuất: Jaya/Skypiea hoặc Water 7).
- Đoạn biển đa dạng (tàu Marine, sóng lớn, Sea King ở nền).
- Hệ trái ác quỷ: pool ngẫu nhiên, giới hạn số lượng.
- Đủ 5 nhân vật: Luffy, Zoro, Nami, Sanji, Usopp.

**Tiêu chí hoàn thành**
- [ ] FR-IT-04 đạt; mô phỏng 10.000 run cho phân phối trái ác quỷ đúng cấu hình.
- [ ] Một run tốt kéo dài ≥ 10 phút trước khi hết nội dung.

---

## M7 — Meta & cạnh tranh

**Phạm vi**
- Berries, cửa hàng nâng cấp, mở khoá nhân vật/skin.
- Bảng xếp hạng online (chọn dịch vụ backend tại thời điểm này — ghi vào decision log).
- Thử thách hằng ngày (seed cố định theo ngày).
- Quyết định câu hỏi `MỞ` về nâng cấp có ảnh hưởng bảng xếp hạng hay không.

**Tiêu chí hoàn thành**: FR-SC-05..07.

---

## M8 — Hoàn thiện & phát hành

**Phạm vi**
- Tối ưu hiệu năng, kích thước bản build.
- Xuất bản Android (AAB) và iOS.
- Icon, ảnh store, mô tả store (vi/en).
- Kiểm thử trên nhiều tỉ lệ màn hình (16:9, 19.5:9, 20:9, iPad 4:3).
- Checklist QA cuối.

**Tiêu chí hoàn thành**: NFR-PF-01, NFR-PF-03; không còn lỗi mức nghiêm trọng.

---

## Sau M8

- Thêm đảo theo đợt cập nhật.
- Content pack nhân vật tự xây dựng hoàn chỉnh.
- Bắt đầu game 2: tách `game/shared/` thành package riêng — xem [reuse for game 2](../05-technical/07-reuse-for-game-2.md).
