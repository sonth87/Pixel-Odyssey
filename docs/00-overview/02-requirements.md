# Yêu cầu (Requirements)

Mỗi yêu cầu có: **ID**, **mô tả**, **vì sao** (phân tích), **tiêu chí chấp nhận** (làm sao biết là xong), **milestone** đầu tiên phải đạt.

Quy ước ID: `FR-<nhóm>-<số>` = yêu cầu chức năng, `NFR-<nhóm>-<số>` = yêu cầu phi chức năng. ID không bao giờ được dùng lại khi xoá.

Thông số cụ thể (tốc độ, độ cao nhảy...) **không** ghi ở đây mà ở tài liệu chuyên môn được link — ở đây chỉ ghi yêu cầu.

---

## 1. Gameplay cốt lõi (GP)

| ID | Yêu cầu | Vì sao | Tiêu chí chấp nhận | MS |
|---|---|---|---|---|
| FR-GP-01 | Nhân vật tự động chạy sang phải với tốc độ tăng dần theo quãng đường | Lõi của thể loại runner; tốc độ tăng tạo áp lực và độ khó tự nhiên | Không có input vẫn chạy; tốc độ đo được tăng theo đường cong ở [physics](../05-technical/05-physics-collision-generation.md) | M1 |
| FR-GP-02 | Chạm = nhảy; giữ = nhảy cao hơn (có giới hạn); thả sớm = nhảy thấp | Một nút nhưng có hai mức điều khiển → chiều sâu kỹ năng | Đo được độ cao nhảy tối thiểu và tối đa đúng thông số ±1 px | M1 |
| FR-GP-03 | Có *coyote time* và *jump buffer* | Người chơi cảm thấy "tôi đã bấm mà sao không nhảy" là lý do số 1 game runner bị chê "cứng tay" | Bấm trễ ≤ coyote time sau khi rời mép vẫn nhảy; bấm sớm ≤ buffer trước khi chạm đất vẫn nhảy khi chạm đất | M1 |
| FR-GP-04 | Va chạm chướng ngại vật/kẻ địch (không có bảo vệ) = chết ngay | Một mạng → mỗi quyết định có trọng lượng | Va chạm → trạng thái chết, dừng điểm, mở màn kết quả | M1 |
| FR-GP-05 | Rơi xuống hố = chết | Hố là loại chướng ngại thứ hai, buộc phải nhảy đúng thời điểm chứ không chỉ "nhảy là xong" | Rơi dưới mép màn hình → chết | M1 |
| FR-GP-06 | Chết → màn kết quả → chạm "chơi lại" bắt đầu run mới **từ đầu hành trình** | Yêu cầu chủ dự án; giữ giá trị cạnh tranh của điểm | Từ lúc chết tới lúc điều khiển được run mới ≤ 1 giây (trừ animation chết), tối đa 1 chạm | M1 |
| FR-GP-07 | Hitbox nhân vật nhỏ hơn hình vẽ; hitbox chướng ngại vật thu nhỏ so với hình | "Suýt chạm nhưng không chết" tạo cảm giác công bằng; chạm vào phần trống của hình mà chết tạo cảm giác bị lừa | Có chế độ debug hiện hitbox; kích thước theo [physics](../05-technical/05-physics-collision-generation.md) | M1 |
| FR-GP-08 | Địa hình có thể lên/xuống bậc (bậc thang, mái nhà thấp, sàn tàu) | Yêu cầu "bậc thang, công trình"; tạo nhịp khác ngoài nhảy qua vật | Nhân vật đứng được trên bậc cao hơn; bậc cao tối đa luôn với tới được | M3 |
| FR-GP-09 | Chướng ngại vật trên không (chim, đạn pháo bay ngang, dây treo) ở độ cao phạt việc nhảy quá cao | Làm cho "giữ" và "chạm nhẹ" đều có lý do; nếu không người chơi chỉ cần luôn nhảy cao nhất | Có ít nhất 1 mẫu đoạn buộc phải nhảy thấp | M3 |
| FR-GP-10 | Perfect Jump: vượt chướng ngại vật với khoảng hở rất nhỏ → thưởng điểm + combo + hiệu ứng | Tạo trần kỹ năng (skill ceiling) mà người mới không bị phạt | Phát hiện đúng theo ngưỡng ở [core gameplay](../01-game-design/01-core-gameplay.md); có âm thanh + chữ PERFECT | M4 |
| FR-GP-11 | Tạm dừng: tự động khi app chạy nền; nút pause trên màn hình | Mobile bị gián đoạn liên tục (cuộc gọi, thông báo) | Chuyển app ra nền rồi quay lại: game ở trạng thái pause, có đếm ngược 3-2-1 khi tiếp tục | M4 |
| FR-GP-12 | Va chạm được xử lý đúng [ma trận tương tác](../01-game-design/09-interaction-rules.md) và thứ tự xử lý mỗi tick | Luật chơi phải nhất quán, dự đoán được | Mỗi ô của ma trận có một test tự động pass | M1 (thường, khiên) / M2 (đủ) |
| FR-GP-13 | Đạp kẻ địch `stompable` khi rơi từ trên → hạ kẻ địch, nảy lên (giữ để nảy cao) | Tương tác chủ động một nút (D-022) | Test đạp từ trên = hạ; chạm cạnh khi đang rơi = chết | M1 |
| FR-GP-14 | Corner correction và tự bước lên bậc thấp | Tránh chết oan khi thiếu vài pixel | Test thiếu 6 px lên bậc, thiếu 7 px chết `WALL` | M1 |
| FR-GP-15 | Kẻ địch có hành vi (lao tới, tuần tra, nhảy lên, bay, bắn, rơi, quét) kích hoạt theo vị trí người chơi, có báo trước | Thế giới sống động mà vẫn công bằng, tất định (D-025) | Mỗi hành vi có ít nhất 1 kẻ địch dùng; validator mô phỏng được | M1 (lao tới) / M3 (đủ) |

## 2. Thế giới, đảo, đoạn (WD)

| ID | Yêu cầu | Vì sao | Tiêu chí chấp nhận | MS |
|---|---|---|---|---|
| FR-WD-01 | Một run đi qua chuỗi **đảo** theo thứ tự cố định (theo truyện), giữa các đảo là **đoạn biển** chạy trên tàu | Cảm giác "hành trình"; cảnh vật tự tạo cảm giác tiến bộ | Run bắt đầu ở đảo đầu tiên của hành trình, qua đảo → biển → đảo kế tiếp không có màn loading | M3 |
| FR-WD-02 | Mỗi đảo chia thành các **đoạn (segment)** có độ dài cố định theo % quãng đường của đảo, mỗi đoạn có bối cảnh cố định | Yêu cầu chủ dự án (ví dụ Alabasta 5 đoạn × 20%) | Đoạn chuyển đúng vị trí; nền đúng bối cảnh đoạn | M3 |
| FR-WD-03 | Chướng ngại vật trong đoạn được tạo **ngẫu nhiên có kiểm soát** từ thư viện **mẫu đoạn (chunk)** đã kiểm định | Mỗi lần chơi khác nhau nhưng luôn vượt qua được | Hai run khác seed có chuỗi chunk khác nhau; công cụ kiểm định báo 100% chunk vượt qua được | M1 (greybox) / M3 |
| FR-WD-04 | **Không bao giờ** có đoạn không thể vượt qua: hố rộng hơn tầm nhảy, tường cao hơn tầm nhảy, hai vật cản liên tiếp không đủ chỗ đáp | Trụ cột "luôn công bằng" | Validator tự động mô phỏng nhảy chạy cho mọi chunk ở mọi tốc độ của đoạn chứa nó | M1 |
| FR-WD-05 | Nền **parallax** nhiều lớp, mỗi lớp trôi tốc độ khác nhau | Chiều sâu thị giác rẻ mà hiệu quả | Đúng số lớp và hệ số trôi ở [đặc tả nền](../02-art/03-environment-parallax-spec.md) | M3 |
| FR-WD-06 | NPC nền (dân, động vật) mặc trang phục theo đảo; mật độ thay đổi theo đoạn (sa mạc thưa → thành phố đông) | Yêu cầu chủ dự án; kể chuyện bằng môi trường | Mật độ NPC theo cấu hình đoạn | M3 |
| FR-WD-07 | Sự kiện boss là **sự kiện nền** (chỉ hình ảnh) hoặc **chuỗi chướng ngại vật đặc biệt** — không có chiến đấu | Giữ one-button; vẫn epic | Ví dụ Alabasta: Crocodile ở nền + chuỗi "lưỡi cát" phải nhảy qua | M3 |
| FR-WD-08 | Chuyển từ đảo sang tàu bằng cú nhảy thật (không cắt cảnh) | "Signature" của game theo brainstorm | Cuối đảo có mép đất + tàu; nhân vật nhảy lên tàu và chạy tiếp; nhảy hụt = rơi xuống biển = chết | M3 |
| FR-WD-09 | Lớp tiền cảnh (foreground) không được che nhân vật hoặc chướng ngại vật sắp tới | Che khuất = chết không công bằng | Quy tắc vùng cấm ở đặc tả nền; validator kiểm tra | M3 |
| FR-WD-10 | Mọi mối nguy có thời gian phản ứng ≥ 0.70 s và tốc độ tiếp cận ≤ 365 px/s ở trạng thái thường | Trụ cột "luôn công bằng" (D-019) | Validator báo xanh cho mọi chunk | M1 |
| FR-WD-11 | NPC nền ba hạng (ambient, reactive, set-piece), không ảnh hưởng gameplay | Thế giới sống động (D-026) | Alabasta có đủ ba hạng; NPC không có hitbox | M3 |
| FR-IT-06 | Mọi item/nội tại/dạng biến hình tuân thủ bất biến E1–E4 | Hiệu ứng không được tạo tình huống không thể vượt qua (D-020) | ContentRegistry từ chối pack vi phạm; có test | M2 |

## 3. Nhân vật (CH)

| ID | Yêu cầu | Vì sao | Tiêu chí chấp nhận | MS |
|---|---|---|---|---|
| FR-CH-01 | Nhân vật được định nghĩa hoàn toàn bằng **dữ liệu** (thông số, nội tại, bộ animation, âm thanh, dạng biến hình) | W7: đổi chủ đề không sửa code | Thêm nhân vật mới chỉ bằng file dữ liệu + asset, không sửa code gameplay | M5 |
| FR-CH-02 | Mọi nhân vật dùng **bộ tên trạng thái animation chuẩn** giống nhau | Code không viết riêng từng nhân vật; dùng lại cho game 2 | Kiểm tra tự động: bộ animation của nhân vật có đủ các trạng thái bắt buộc | M2 |
| FR-CH-03 | Mỗi nhân vật có 1 **nội tại (passive)** khác nhau | Lý do để chọn nhân vật khác nhau mà không thêm nút | Bảng nội tại ở [nhân vật](../01-game-design/03-characters-and-skills.md) | M5 |
| FR-CH-04 | Mỗi nhân vật có **dạng biến hình đặc trưng** kích hoạt bởi item biến hình | "Ăn thịt → Gear 4" nhưng tổng quát cho mọi nhân vật | Cùng 1 item, mỗi nhân vật biến hình khác nhau | M2 (Luffy) / M5 |
| FR-CH-05 | Chọn nhân vật trước khi chạy | | Màn chọn nhân vật, lưu lựa chọn gần nhất | M5 |

## 4. Item và năng lực (IT)

| ID | Yêu cầu | Vì sao | Tiêu chí chấp nhận | MS |
|---|---|---|---|---|
| FR-IT-01 | Item tạo hiệu ứng theo 3 kiểu thời hạn: **theo thời gian**, **theo số lần**, **tức thì** | Yêu cầu chủ dự án ("1 lần, vài lần, theo thời gian") | Mỗi kiểu có ít nhất 1 item hoạt động | M2 |
| FR-IT-02 | Hiệu ứng item là **tổ hợp các hiệu ứng nguyên tố** (khiên, đổi tốc độ, đổi kích thước, phá vật cản, đổi lực nhảy, nam châm, nhân điểm, đi xuyên...) | Thêm item mới = ghép hiệu ứng có sẵn, không viết code mới | Item mới tạo được chỉ bằng dữ liệu | M2 |
| FR-IT-03 | Item xuất hiện ở các **vị trí đặt item** định sẵn trong chunk, có nhãn an toàn/mạo hiểm | Risk/reward: item tốt đặt ở chỗ khó lấy | Chunk có điểm đặt item; tỉ lệ theo cấu hình | M2 |
| FR-IT-04 | Trái ác quỷ: ngẫu nhiên trong danh sách, **giới hạn số lượng** mỗi đảo/đoạn | Yêu cầu chủ dự án; chấp nhận may rủi | Không vượt quá giới hạn cấu hình; phân phối đúng trọng số qua 10.000 lần mô phỏng | M6 |
| FR-IT-05 | Khi có nhiều hiệu ứng cùng lúc, quy tắc chồng hiệu ứng rõ ràng | Tránh bug "ăn 2 item thì vô địch vĩnh viễn" | Quy tắc ở [item](../01-game-design/04-items-and-powerups.md); có test | M2 |

## 5. Điểm, tiến trình, meta (SC)

| ID | Yêu cầu | Vì sao | Tiêu chí chấp nhận | MS |
|---|---|---|---|---|
| FR-SC-01 | Hiển thị quãng đường (m) liên tục | Thước đo chính | HUD hiện m; đổi px → m theo hằng số | M1 |
| FR-SC-02 | Điểm số = quãng đường + điểm thưởng × hệ số combo | Hai kiểu người chơi: đi xa vs điểm cao | Công thức ở [điểm](../01-game-design/05-scoring-progression-meta.md) | M4 |
| FR-SC-03 | Lưu kỷ lục cá nhân trên máy | | Kỷ lục còn sau khi tắt app | M4 |
| FR-SC-04 | Ghi nhận "đảo xa nhất từng tới" (chỉ để hiển thị, **không** phải checkpoint) | Người chơi thấy mình tiến bộ trên hành trình | Màn kết quả hiện đảo xa nhất | M4 |
| FR-SC-05 | Tiền trong game (Berries) kiếm sau mỗi run, dùng mở khoá/nâng cấp | Giữ chân dài hạn | Xem [meta](../01-game-design/05-scoring-progression-meta.md) | M7 |
| FR-SC-06 | Bảng xếp hạng online | Cạnh tranh | Thiết kế ở M7 | M7 |
| FR-SC-07 | Chế độ thử thách hằng ngày dùng seed cố định | Công bằng tuyệt đối cho người muốn thi đấu | Hai máy cùng ngày, cùng seed → cùng chuỗi chunk và item | M7 |

## 6. Giao diện, cài đặt (UI)

| ID | Yêu cầu | Vì sao | Tiêu chí chấp nhận | MS |
|---|---|---|---|---|
| FR-UI-01 | Luồng màn hình: khởi động → menu → (chọn nhân vật) → chạy → kết quả → chạy lại | | Xem [player experience](../06-user/01-player-experience.md) | M4 |
| FR-UI-02 | Cài đặt: âm lượng nhạc/hiệu ứng, ngôn ngữ, rung, rung màn hình, giảm nhấp nháy | Accessibility + thói quen mobile | Mỗi cài đặt có tác dụng ngay và được lưu | M4 |
| FR-UI-03 | Hướng dẫn chơi lồng vào run đầu tiên (không có màn hướng dẫn riêng) | Người chơi casual bỏ qua chữ | Lần đầu chơi: hình bàn tay chỉ "chạm để nhảy" trước vật cản đầu tiên | M4 |

## 7. Ngôn ngữ (LC) và âm thanh (AU)

| ID | Yêu cầu | Vì sao | Tiêu chí chấp nhận | MS |
|---|---|---|---|---|
| FR-LC-01 | Hỗ trợ tiếng Việt và tiếng Anh từ đầu | Không hard-code chữ để không phải sửa lại toàn bộ sau | Không có chuỗi hiển thị nào nằm trong code; đổi ngôn ngữ trong cài đặt đổi toàn bộ chữ | M4 |
| FR-LC-02 | Font pixel hiển thị đúng **toàn bộ dấu tiếng Việt** | Rất nhiều font pixel không có dấu tiếng Việt | Trang kiểm tra font hiện đủ "ẮẰẲẴẶ ẤẦẨẪẬ ỆỄ Ữ Ự..." không vỡ | M4 |
| FR-LC-03 | Chữ thuộc content pack (tên nhân vật, item, đảo) nằm trong content pack | Đổi chủ đề đổi luôn tên | Đổi pack → tên đổi | M5 |
| FR-AU-01 | Nhạc nền theo đảo, chuyển mượt khi sang đảo/biển | Cảm giác hành trình | Không có khoảng lặng/khựng khi chuyển | M3 |
| FR-AU-02 | Hiệu ứng âm thanh cho mọi hành động người chơi (nhảy, đáp, ăn item, perfect, chết) | Phản hồi tức thì | Danh sách ở [audio](../03-audio/01-audio-spec.md) đủ | M2 |
| FR-AU-03 | Âm lượng tách kênh nhạc / hiệu ứng / UI / ambience | Cài đặt người dùng | Bus audio đúng cấu trúc | M4 |

---

## 8. Phi chức năng (NFR)

| ID | Yêu cầu | Vì sao | Tiêu chí chấp nhận | MS |
|---|---|---|---|---|
| NFR-PF-01 | 60 FPS ổn định trên điện thoại Android tầm trung đời 2020 trở lên | Runner tốc độ cao, khựng hình = chết oan | Đo trên máy thật trong 10 phút chạy liên tục; không tụt dưới 55 FPS | M8 (đo từ M3) |
| NFR-PF-02 | Không tạo/huỷ object liên tục trong lúc chạy; dùng object pool | Giật do bộ nhớ | Profiler không có spike khi spawn | M3 |
| NFR-PF-03 | Khởi động tới menu ≤ 3 giây | | Đo trên máy tầm trung | M8 |
| NFR-VS-01 | Pixel-perfect: 1 pixel art = 1 pixel logic; phóng to bằng số nguyên; lọc ảnh Nearest | Pixel bị nhoè/méo làm hỏng toàn bộ phong cách | Ảnh chụp màn hình phóng to: mọi pixel vuông, cạnh sắc | M0 |
| NFR-VS-02 | Không trộn mật độ pixel khác nhau trong cùng cảnh (trừ ngoại lệ UI đã ghi) | Như trên | Review art theo [style guide](../02-art/01-art-style-guide.md) | M2 |
| NFR-DT-01 | Run có tính tất định (deterministic) theo seed cho phần gameplay | Thử thách hằng ngày, tái hiện bug | Cùng seed + cùng input → cùng kết quả trong test tự động | M1 |
| NFR-EX-01 | Thêm nhân vật/đảo/item/obstacle **không cần sửa code gameplay** | W7 | M5: thêm Zoro chỉ bằng dữ liệu + asset | M5 |
| NFR-EX-02 | Đổi content pack (chủ đề) bằng một cấu hình | W7 | M5: đổi sang pack thử nghiệm, mọi hình/chữ/âm đổi theo | M5 |
| NFR-MT-01 | Tuân thủ [quy tắc code](../05-technical/03-coding-standards.md) | W10 | Review mỗi thay đổi | M0 |
| NFR-MT-02 | Lớp `shared` không phụ thuộc lớp `runner` hay content | Để tách sang game 2 | Kiểm tra tự động bằng script tìm import sai chiều | M1 |
| NFR-QA-01 | Có chế độ debug: hiện hitbox, chỉnh tốc độ, bất tử, nhảy thẳng tới đoạn bất kỳ, nhập seed | Tiết kiệm thời gian test | Bật/tắt bằng phím/cử chỉ trong bản dev, không có trong bản release | M1 |
| NFR-AC-01 | Tuỳ chọn giảm nhấp nháy cho hiệu ứng chớp sáng (sấm sét Wano...) | Người nhạy cảm ánh sáng | Bật tùy chọn → chớp thay bằng đổi màu nhẹ | M4 |
| NFR-AC-02 | Chướng ngại vật phân biệt được bằng **hình dáng**, không chỉ bằng màu | Mù màu | Review art | M3 |
| NFR-OF-01 | Chơi được hoàn toàn offline (trừ bảng xếp hạng) | Mobile mất mạng | Tắt mạng vẫn chơi, lưu bình thường | M4 |
| NFR-SV-01 | Dữ liệu lưu có số phiên bản và cơ chế nâng cấp dữ liệu cũ | Cập nhật game không làm mất tiến trình | Test nạp file lưu phiên bản cũ | M4 |
