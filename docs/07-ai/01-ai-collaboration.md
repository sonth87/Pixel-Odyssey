# Làm việc với AI

File này dành cho hai đối tượng:
- **Phần A** — AI agent viết code/tài liệu trong repo (Claude Code và các agent khác).
- **Phần B** — chủ dự án dùng AI tạo ảnh/âm thanh.

---

## Phần A — Dành cho AI agent

Quy tắc ngắn gọn bắt buộc nằm ở [/CLAUDE.md](../../CLAUDE.md). Phần này giải thích chi tiết.

### A1. Bối cảnh cần biết

- Chủ dự án **không phải nhà phát triển game chuyên nghiệp** và muốn AI **chủ động tư vấn**: khi một yêu cầu có hệ quả về game design/kỹ thuật mà họ có thể chưa thấy (cảm giác chơi, hiệu năng, khả năng mở rộng, tái sử dụng cho game 2), hãy nói ra ngắn gọn kèm đề xuất.
- Ngôn ngữ trao đổi: **tiếng Việt**. Code, tên biến, commit message: tiếng Anh. Tài liệu: tiếng Việt (prompt ảnh/âm: tiếng Anh).
- Dự án có hai game; repo này là game 1 (runner). Đừng thiết kế gameplay chung cho cả hai (D-007).
- Chủ đề bản quyền: **không bàn** cho tới khi chủ dự án mở lại (D-011).

### A2. Đọc gì trước khi làm

| Việc | Đọc |
|---|---|
| Bất kỳ việc gì | `CLAUDE.md`, [decision log](../00-overview/04-decision-log.md), [milestones](../00-overview/03-milestones.md) (biết đang ở milestone nào) |
| Code gameplay | [architecture](../05-technical/01-architecture.md), [coding standards](../05-technical/03-coding-standards.md), [physics](../05-technical/05-physics-collision-generation.md), file game design liên quan |
| Thêm dữ liệu/nội dung | [data schemas](../05-technical/04-data-schemas.md), skill tương ứng |
| Art/prompt | [style guide](../02-art/01-art-style-guide.md), [prompt library](../02-art/06-prompt-library.md), đặc tả tương ứng |
| Âm thanh | [audio](../03-audio/01-audio-spec.md) |
| Chữ hiển thị | [localization](../04-localization/01-localization.md) |

### A3. Quy tắc làm việc

1. **Tài liệu là nguồn sự thật.** Yêu cầu mới mâu thuẫn tài liệu → chỉ ra mâu thuẫn, hỏi hoặc (nếu rõ ràng là chủ dự án đổi ý) cập nhật tài liệu **và** thêm mục decision log, rồi mới code.
2. **Không tự quyết câu hỏi `MỞ`.** Cần giá trị để làm tiếp → dùng phương án tạm, đánh dấu rõ là tạm, báo lại.
3. **Phân biệt `CHỐT` và `ĐỀ XUẤT`.** Được phép chỉnh `ĐỀ XUẤT` khi có lý do (ví dụ test cho thấy cần) — ghi lại lý do.
4. **Giữ phạm vi milestone.** Không làm trước tính năng của milestone sau trừ khi được yêu cầu.
5. **Dùng skill quy trình** khi việc khớp: `add-character`, `add-island`, `add-content`, `sprite-pipeline`, `add-audio`, `record-decision`.
6. **Sau khi đổi thông số vật lý/chunk**: chạy validator.
7. **Comment code** theo [coding standards §3](../05-technical/03-coding-standards.md#3-comment): mô tả hiện tại, không lịch sử thay đổi, không nhắc yêu cầu/người dùng.
8. **Báo cáo trung thực**: chưa chạy được/chưa test được thì nói rõ.

### A4. Cập nhật tài liệu

- Đổi hành vi/thông số/quy tắc → cập nhật đúng file nguồn của thông tin đó (mỗi thông tin một nguồn — xem [docs/README](../README.md)).
- Quyết định mới → `record-decision`.
- Hoàn thành milestone → cập nhật checklist trong milestones + số liệu thật (thời gian, thông số đã chỉnh).
- Tài liệu viết theo hiện tại, không viết "đã đổi từ...".

### A5. Skill trong `.claude/skills/`

| Skill | Khi nào |
|---|---|
| `add-character` | Thêm nhân vật mới vào content pack |
| `add-island` | Thêm đảo / đoạn biển / đoạn / chunk |
| `add-content` | Thêm chướng ngại vật, kẻ địch, item, NPC, VFX |
| `sprite-pipeline` | Xử lý ảnh AI thành sprite và đưa vào game |
| `add-audio` | Thêm nhạc / SFX / ambience |
| `record-decision` | Ghi một quyết định vào decision log và cập nhật tài liệu liên quan |

Skill cộng đồng (skills.sh): tại 2026-10-01 không có skill nào về Godot / pixel art / game dev. Trước khi cài skill bên ngoài: đọc toàn bộ nội dung (skill có thể chạy lệnh), ghi vào decision log.

---

## Phần B — Dành cho chủ dự án: dùng AI tạo asset

### B1. Ảnh
- Quy trình đầy đủ: [AI image pipeline](../02-art/05-ai-image-pipeline.md).
- Prompt: [prompt library](../02-art/06-prompt-library.md) + mục prompt trong từng file đặc tả.
- Mẹo quan trọng nhất: **gen một frame chuẩn, mọi frame khác dùng chế độ chỉnh sửa (O-EDIT) từ frame đó**, đính kèm ảnh tham chiếu.
- Lưu prompt đã dùng cạnh ảnh gốc.

### B2. Âm thanh
- [audio spec](../03-audio/01-audio-spec.md) có prompt cho nhạc (Suno/Udio) và SFX (ElevenLabs) + thông số sfxr.

### B3. Nhờ Claude giúp phần asset
Có thể yêu cầu:
- "Viết prompt cho animation `<tag>` của `<nhân vật>`" → Claude ghép theo prompt library.
- "Xử lý ảnh `<đường dẫn>`" → Claude chạy `tools/pixelize.py`, báo kết quả, kiểm tra theo checklist.
- "Kiểm tra sprite sheet `<đường dẫn>` có đúng chuẩn không" → Claude kiểm tra kích thước khung, pivot, số màu, alpha.
- "Tạo đặc tả cho đảo `<tên>`" → theo mẫu [Alabasta](../01-game-design/07-island-alabasta.md).
