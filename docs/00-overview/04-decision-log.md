# Nhật ký quyết định (Decision log)

Mỗi quyết định quan trọng ghi một mục. **Không xoá mục cũ**; khi đổi ý, thêm mục mới và đánh dấu mục cũ là `THAY BỞI D-xxx`.

Trạng thái: `CHỐT` (chủ dự án xác nhận) · `ĐỀ XUẤT` (dùng để bắt đầu, có thể đổi) · `MỞ` (chưa quyết, không được tự giả định) · `THAY BỞI D-xxx`.

Mẫu:
```
## D-xxx — Tiêu đề
- Ngày: YYYY-MM-DD · Trạng thái: ...
- Bối cảnh: vấn đề gì cần quyết
- Quyết định: chọn gì
- Vì sao: lý do, phương án khác đã cân nhắc
- Hệ quả: ảnh hưởng tới đâu (tài liệu/code nào)
```

---

## D-001 — Thể loại: endless runner một nút
- Ngày: 2026-10-01 · Trạng thái: `CHỐT`
- Bối cảnh: ý tưởng ban đầu gọi là "idle 8-bit" nhưng mô tả thực chất là runner kiểu Flappy Bird / khủng long Chrome.
- Quyết định: endless runner / one-tap arcade. Yếu tố "idle" (nếu có) chỉ nằm ở meta (tiền, nâng cấp), không ở lối chơi.
- Vì sao: lối chơi chạm-để-nhảy không phải idle theo nghĩa truyền thống; gọi đúng tên để thiết kế đúng.
- Hệ quả: toàn bộ [core gameplay](../01-game-design/01-core-gameplay.md).

## D-002 — Chết là chơi lại từ đầu, không hồi sinh, không checkpoint
- Ngày: 2026-10-01 · Trạng thái: `CHỐT`
- Bối cảnh: brainstorm từng đề xuất lưu tiến trình hành trình giữa các run.
- Quyết định: chết → run mới từ đảo đầu tiên. "Đảo xa nhất" chỉ lưu để hiển thị.
- Vì sao: giữ giá trị cạnh tranh của điểm/quãng đường; tới được màn cuối là thành tích kỹ năng.
- Hệ quả: FR-GP-06, FR-SC-04; không có tính năng hồi sinh trả tiền.

## D-003 — Stage/Run là hai khái niệm khác nhau; cấu trúc Hành trình → Đảo → Đoạn → Chunk
- Ngày: 2026-10-01 · Trạng thái: `CHỐT` (cấu trúc), `ĐỀ XUẤT` (tên gọi)
- Quyết định: một **run** đi qua **hành trình** gồm các **đảo**; đảo chia **đoạn** cố định theo %; đoạn được lấp bằng **chunk** chọn ngẫu nhiên có kiểm soát.
- Hệ quả: [run & stages](../01-game-design/02-run-journey-and-stages.md), [schemas](../05-technical/04-data-schemas.md).

## D-004 — Ngẫu nhiên có kiểm soát: nền/đoạn cố định, chướng ngại vật ngẫu nhiên từ mẫu đã kiểm định
- Ngày: 2026-10-01 · Trạng thái: `CHỐT` (nguyên tắc), `ĐỀ XUẤT` (cách làm bằng chunk pool)
- Bối cảnh: map cố định hoàn toàn thì nhàm; random tự do thì có đoạn không qua được.
- Quyết định: mỗi đoạn có thư viện chunk thiết kế tay, mỗi chunk đã được validator chứng minh vượt qua được; khi chạy chọn ngẫu nhiên có trọng số.
- Vì sao: cách làm phổ biến của các runner thành công; rẻ hơn và an toàn hơn sinh ngẫu nhiên tự do rồi kiểm tra lúc chạy.

## D-005 — Chấp nhận may rủi về item
- Ngày: 2026-10-01 · Trạng thái: `CHỐT`
- Quyết định: item/trái ác quỷ ngẫu nhiên trong giới hạn; người này có thể may hơn người kia.
- Vì sao: phần thưởng biến thiên tạo động lực chơi lại. Ai muốn công bằng tuyệt đối có chế độ thử thách hằng ngày (seed cố định, D-012).

## D-006 — Tách engine/gameplay khỏi content pack
- Ngày: 2026-10-01 · Trạng thái: `CHỐT`
- Quyết định: code chỉ biết khái niệm trung lập (runner, obstacle, power-up, stage...). One Piece là content pack đầu tiên.
- Vì sao: đổi chủ đề (nhân vật tự xây dựng hoặc chủ đề khác) không sửa logic.
- Hệ quả: quy tắc đặt tên trung lập trong code; M5 chứng minh.

## D-007 — Hai game dùng chung nội dung và tiện ích, không dùng chung gameplay
- Ngày: 2026-10-01 · Trạng thái: `CHỐT` (có game 2), `ĐỀ XUẤT` (ranh giới chia sẻ)
- Quyết định: lớp `shared` = art, animation chuẩn, dữ liệu nhân vật/skill, âm thanh, ngôn ngữ, tiện ích kỹ thuật. Gameplay runner và gameplay hành động viết riêng.
- Vì sao: vật lý runner và combat hành động khác bản chất; ép chung → over-engineering.
- Hệ quả: [reuse for game 2](../05-technical/07-reuse-for-game-2.md).

## D-008 — Phạm vi lớn, triển khai theo milestone, vertical slice trước
- Ngày: 2026-10-01 · Trạng thái: `CHỐT`
- Bối cảnh: chủ dự án không muốn MVP quá nhỏ ("ít quá chẳng ai chơi").
- Quyết định: tầm nhìn lớn nằm trong roadmap; xây theo milestone, mỗi milestone chơi được; một nhân vật và một đảo trọn vẹn trước khi nhân rộng.
- Hệ quả: [milestones](03-milestones.md).

## D-009 — Phong cách art: chuẩn theo ảnh nhân vật hiện có
- Ngày: 2026-10-01 · Trạng thái: `CHỐT`
- Bối cảnh: 3 ảnh `assets/1.jpg`, `2.jpg`, `3.jpg` chỉ là ví dụ minh hoạ ý tưởng nền, không phải phong cách đích.
- Quyết định: chuẩn phong cách là ảnh trong `assets/charactors/`. Đo thực tế: pixel art thật trên lưới 64×64, nhân vật cao ~22–24 px, chibi, không viền đen, tô phẳng 2–3 sắc độ, phóng to 16–22 lần khi xuất ảnh.
- Hệ quả: [style guide](../02-art/01-art-style-guide.md). Nền phải vẽ cùng mật độ pixel, cùng mức chi tiết với nhân vật.

## D-010 — Animation chiêu thức chia 3 pha startup / active / recovery
- Ngày: 2026-10-01 · Trạng thái: `CHỐT`
- Quyết định: mọi animation skill vẽ thành 3 đoạn riêng. Game 1 có thể chỉ dùng hình ảnh; game 2 dùng để tính thời điểm gây sát thương.
- Vì sao: vẽ chia pha từ đầu tốn thêm rất ít, tránh vẽ lại khi làm game 2.

## D-011 — Bỏ qua chủ đề bản quyền trong giai đoạn này
- Ngày: 2026-10-01 · Trạng thái: `CHỐT`
- Quyết định: không bàn trong tài liệu/thảo luận cho tới khi chủ dự án mở lại. Kiến trúc content pack (D-006) vẫn giữ.

## D-012 — RNG có seed, tách luồng
- Ngày: 2026-10-01 · Trạng thái: `ĐỀ XUẤT`
- Quyết định: mỗi run có một seed; các luồng ngẫu nhiên tách riêng (chunk, item, trang trí). Trang trí (NPC, mây) không được làm thay đổi chuỗi gameplay.
- Vì sao: làm từ đầu gần như miễn phí; thêm sau rất tốn công. Cho phép thử thách hằng ngày và tái hiện bug.

## D-013 — Engine Godot 4, GDScript có kiểu tĩnh
- Ngày: 2026-10-01 · Trạng thái: `ĐỀ XUẤT`
- Vì sao: 2D/pixel art tốt, miễn phí, nhẹ, hệ Resource phù hợp thiết kế hướng dữ liệu, có Parallax2D. Phương án khác: Unity (nặng hơn cho 2D đơn giản, licensing phức tạp), Phaser/web (mobile native kém hơn).
- Việc cần làm ở M0: ghi số phiên bản cụ thể.

## D-014 — Độ phân giải logic 320×180, phóng to số nguyên, chiều rộng mở rộng theo màn hình
- Ngày: 2026-10-01 · Trạng thái: `ĐỀ XUẤT`
- Vì sao: nhân vật cao 24 px chiếm ~13% chiều cao màn hình — tỉ lệ tương tự khủng long Chrome, đủ nhìn rõ chướng ngại vật phía trước. 320×180 nhân nguyên 4 → 1280×720, 6 → 1920×1080. Màn hình dài (19.5:9, 20:9) thấy thêm phía trước một chút (tối đa 400 px).
- Đánh đổi: màn hình rộng thấy trước xa hơn → hơi lợi thế. Chấp nhận (phù hợp D-005); nếu cần công bằng tuyệt đối cho bảng xếp hạng, xem lại ở M7.

## D-015 — Comment code mô tả hiện tại, không mô tả lịch sử thay đổi
- Ngày: 2026-10-01 · Trạng thái: `CHỐT`
- Quyết định: không viết comment kiểu "sửa theo yêu cầu", "đổi từ X sang Y", "trước đây là...". Lịch sử nằm trong git và decision log.
- Vì sao: giai đoạn đầu mọi thứ thay đổi liên tục; comment lịch sử nhanh chóng sai và gây nhiễu.

## D-016 — Bảng xếp hạng chính theo quãng đường, phụ theo điểm
- Ngày: 2026-10-01 · Trạng thái: `ĐỀ XUẤT`
- Vì sao: yêu cầu gốc "tính điểm đi được xa nhất"; điểm (combo, perfect) phục vụ người chơi thích kỹ thuật.

## D-017 — UI vẽ ở lưới 640×360 (gấp đôi lưới thế giới)
- Ngày: 2026-10-01 · Trạng thái: `ĐỀ XUẤT`
- Vì sao: chữ tiếng Việt có dấu chồng nhiều tầng (ệ, ặ, ữ) cần nhiều pixel chiều cao; ở 320×180 chữ quá to so với màn hình. Đây là ngoại lệ duy nhất của quy tắc "không trộn mật độ pixel" (NFR-VS-02).
- Lưu ý từ đánh giá 2026-10-01: trộn hai mật độ trong **cùng một khung hình** (HUD đè lên thế giới) trông lệch. Phương án đang cân nhắc: HUD chỉ dùng số + biểu tượng ở lưới thế giới; chỉ màn hình nhiều chữ (menu, cài đặt, kết quả) dùng lưới 640×360. Quyết định khi viết đặc tả màn hình (M4).

## D-018 — Tốc độ khai báo theo đảo (đầu → cuối), trần tốc độ gốc 300 px/s
- Ngày: 2026-10-01 · Trạng thái: `ĐỀ XUẤT`
- Bối cảnh: công thức tốc độ theo tổng quãng đường chạm trần ở 4.500 m, sau đó tốc độ thực tế chỉ do kẹp theo đảo quyết định — đường cong tăng tốc không được thiết kế thật.
- Quyết định: mỗi đảo có `speed_start` → `speed_end`, tăng tuyến tính trong đảo; đảo sau bắt đầu bằng tốc độ cuối của đảo trước; trần tốc độ gốc 300 px/s.
- Hệ quả: [physics §3](../05-technical/05-physics-collision-generation.md#3-tốc-độ-chạy), `IslandData`.

## D-019 — Luật công bằng: thời gian phản ứng ≥ 0.70 s, trần tốc độ tiếp cận 365 px/s
- Ngày: 2026-10-01 · Trạng thái: `ĐỀ XUẤT`
- Bối cảnh: luật cũ "nhìn thấy ≥ 0.8 s" bị chính thông số của tài liệu vi phạm (kẻ địch lao tới ở tốc độ cao chỉ còn 0.64–0.75 s) và chưa tính tới vật chuyển động/báo trước.
- Quyết định: định nghĩa thời gian phản ứng tính cả tín hiệu báo trước và chuyển động thật của vật; tối thiểu 0.70 s; tốc độ tiếp cận ≤ 365 px/s; validator kiểm tra.
- Vì sao 0.70 s: phản xạ ~0.25 s + quyết định + lấy đà; tương đương khủng long Chrome ở tốc độ tối đa.

## D-020 — Bất biến hiệu ứng E1–E4
- Ngày: 2026-10-01 · Trạng thái: `ĐỀ XUẤT`
- Bối cảnh: hiệu ứng đổi tốc độ/lực nhảy/kích thước đưa người chơi ra ngoài vùng validator đã kiểm định (ví dụ hurtbox Gear 4 cao 30 px không chui lọt khe 22–28 px; trái Pika 576 px/s vẫn chết vì hố).
- Quyết định: hiệu ứng chỉ được làm người chơi an toàn hơn trạng thái thường: tăng tốc → kèm `rush`; biến hình/phóng to → phá mọi vật khi chạm; tăng lực nhảy → phá vật bay/rơi/đạn; không hiệu ứng nào làm chậm/nhảy thấp/thu nhỏ. `ContentRegistry` kiểm tra khi nạp.
- Vì sao: rẻ hơn nhiều so với cho validator mô phỏng mọi tổ hợp hiệu ứng.
- Hệ quả: Pika 1.5× + rush; Cola 1.3× + rush; Gomu `jump_mult 1.3` + phá vật trên không; Gear 4 bỏ "chạy nhanh hơn"; Chopper Monster Point bỏ "chậm hơn".

## D-021 — Chuỗi chunk và item chỉ phụ thuộc (seed, quãng đường)
- Ngày: 2026-10-01 · Trạng thái: `ĐỀ XUẤT`
- Bối cảnh: chọn chunk theo "tốc độ hiện tại" (có tính hiệu ứng) làm chuỗi chunk phụ thuộc việc ăn item → hai người cùng seed gặp chuỗi khác nhau, phá thử thách hằng ngày.
- Quyết định: lọc chunk theo tốc độ gốc; item quyết định lúc dựng chunk; giới hạn item tính theo số đã sinh.

## D-022 — Có cơ chế đạp kẻ địch
- Ngày: 2026-10-01 · Trạng thái: `ĐỀ XUẤT`
- Bối cảnh: trước đây chỉ trái Gomu nhắc tới "đáp lên kẻ địch", luật cơ bản không có.
- Quyết định: rơi từ trên xuống kẻ địch `stompable` → hạ kẻ địch, nảy lên (giữ để nảy cao). Validator không dùng đạp để chứng minh chunk.
- Vì sao: tương tác chủ động với kẻ địch mà vẫn một nút; thêm lựa chọn mạo hiểm có thưởng. Phương án khác: mọi kẻ địch chạm là chết (đơn giản như khủng long Chrome) — đơn giản hơn nhưng nghèo tương tác.

## D-023 — `ground_*` nguy hiểm mọi mặt; corner correction 6 px; nguồn chết `WALL`
- Ngày: 2026-10-01 · Trạng thái: `ĐỀ XUẤT`
- Quyết định: chỉ địa hình đứng lên được; chạm cạnh bậc thiếu ≤ 6 px được đẩy lên; thiếu hơn → chết `WALL`. Khiên chỉ đỡ va chạm, không đỡ hố/tường.
- Hệ quả: [luật tương tác](../01-game-design/09-interaction-rules.md).

## D-024 — Mô hình điểm: chỉ hành động có rủi ro mới cho điểm kỹ năng
- Ngày: 2026-10-01 · Trạng thái: `ĐỀ XUẤT`
- Bối cảnh: mô hình cũ cho điểm mỗi vật vượt qua và mỗi xu → điểm phụ thuộc mật độ chunk ngẫu nhiên, và có thể lấn át quãng đường.
- Quyết định: vượt qua thường và xu = 0 điểm (chỉ tăng combo / cho Berries); Perfect và đạp 25 điểm × combo; combo tối đa ×3 ở 40; định nghĩa chính xác "vượt qua" và Perfect.
- Hệ quả: [scoring](../01-game-design/05-scoring-progression-meta.md). D-016 giữ nguyên.

## D-025 — Hành vi kẻ địch kích hoạt theo vị trí người chơi
- Ngày: 2026-10-01 · Trạng thái: `ĐỀ XUẤT`
- Quyết định: mọi chuyển trạng thái (hiện → báo trước → hành động) kích hoạt theo khoảng cách tới người chơi; tham số ngẫu nhiên của hành vi quyết định lúc dựng chunk; validator mô phỏng hành vi bằng cùng code của game.
- Vì sao: cùng chunk ở mọi tốc độ cho cùng tình huống; kiểm định được; tất định.

## D-026 — NPC ba hạng: ambient, reactive, set-piece; không bao giờ ảnh hưởng gameplay
- Ngày: 2026-10-01 · Trạng thái: `ĐỀ XUẤT`
- Hệ quả: [obstacles/enemies/NPC §6](../01-game-design/08-obstacles-enemies-npc.md#6-npc).

## D-027 — Mô phỏng gameplay bằng số nguyên cố định (trả lời Q-08)
- Ngày: 2026-10-01 · Trạng thái: `CHỐT`
- Bối cảnh: số thực có thể cho kết quả khác nhau giữa các loại CPU; muốn thử thách hằng ngày giống hệt nhau trên mọi máy và cho phép server chơi lại run để chống gian lận.
- Quyết định: vị trí, vận tốc, gia tốc của người chơi và mọi vật có hành vi được tính bằng **số nguyên** theo đơn vị nhỏ hơn pixel (đơn vị cụ thể chốt trong tài liệu input/hiển thị/tất định, viết trước M1). Hình ảnh hiển thị đọc từ giá trị nguyên này. Không dùng `float` trong mô phỏng gameplay.
- Vì sao: làm ngay từ đầu gần như không tốn thêm; đổi sau phải viết lại vật lý và validator. Đánh đổi: code khó đọc hơn một chút.
- Hệ quả: bảng thông số ở [physics](../05-technical/05-physics-collision-generation.md) được tính lại theo giá trị nguyên ở M1 (sai khác < 1 px); chống gian lận bằng phát lại khả thi ở M7.

---

## Câu hỏi `MỞ`

| ID | Câu hỏi | Cần quyết trước |
|---|---|---|
| Q-01 | Tên chính thức của game? | M8 |
| Q-02 | Nâng cấp mua bằng Berries (tăng thời gian item...) có làm bảng xếp hạng thiếu công bằng không? Phương án: bảng riêng không nâng cấp / chế độ thử thách hằng ngày bỏ qua nâng cấp / chấp nhận | M7 |
| Q-03 | Bảng xếp hạng chung mọi nhân vật hay riêng từng nhân vật (vì nội tại khác nhau)? | M7 |
| Q-04 | Có kiếm tiền không (quảng cáo, mua skin)? Mô hình nào? | M7 |
| Q-05 | Có hỗ trợ Web không? | M8 |
| Q-06 | Hành trình đầy đủ dừng ở đâu (Wano? Egghead?) và có "kết thúc" không, hay sau đảo cuối lặp lại ở độ khó cao hơn? Đề xuất hiện có: bản phát hành 6 đảo (Foosha → Alabasta, ~11 phút) + vòng lặp khó dần — [run & stages §2.1](../01-game-design/02-run-journey-and-stages.md#21-hành-trình-phát-hành--đề-xuất-cho-q-06-chưa-chốt) | M6 |
| Q-07 | Dịch vụ backend cho bảng xếp hạng | M7 |
