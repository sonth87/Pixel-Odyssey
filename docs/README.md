# Tài liệu dự án — Pixel Runner (tên tạm)

Thư mục này là **nguồn sự thật duy nhất** của dự án. Mọi quyết định, quy tắc, thông số đều phải nằm ở đây. Nếu một điều gì đó chỉ tồn tại trong đầu người làm hoặc trong lịch sử chat, coi như nó chưa tồn tại.

## Cấu trúc

| Thư mục | Dành cho | Nội dung |
|---|---|---|
| [00-overview/](00-overview/) | Tất cả | Tầm nhìn, yêu cầu, milestone, nhật ký quyết định, thuật ngữ, [roadmap + việc + checklist](00-overview/06-roadmap-and-checklists.md) |
| [01-game-design/](01-game-design/) | Game design | Gameplay, run/hành trình/màn, nhân vật, item, điểm, độ khó, đặc tả đảo Alabasta |
| [02-art/](02-art/) | Art | Chuẩn phong cách, đặc tả animation, nền parallax, obstacle/item/VFX/UI, quy trình AI → pixel art, thư viện prompt |
| [03-audio/](03-audio/) | Âm thanh | Nhạc, hiệu ứng âm thanh, ambience, công cụ, thông số kỹ thuật |
| [04-localization/](04-localization/) | Ngôn ngữ | Đa ngôn ngữ, quy ước key, font tiếng Việt |
| [05-technical/](05-technical/) | Dev | Kiến trúc, cấu trúc thư mục, quy tắc code, schema dữ liệu, vật lý, công cụ, tái sử dụng cho game 2 |
| [06-user/](06-user/) | UX | Người chơi mục tiêu, luồng màn hình, cài đặt, accessibility |
| [07-ai/](07-ai/) | AI agent | Cách AI (Claude, v.v.) làm việc trong repo này, skill quy trình |

`1. conversation.md` là **bản ghi brainstorm gốc** — giữ nguyên để tra cứu lý do ban đầu, nhưng **không phải** tài liệu chuẩn. Khi bản gốc và tài liệu trong các thư mục trên khác nhau, tài liệu trong thư mục thắng.

## Thứ tự đọc

- **Người mới vào dự án**: [00-overview/01-vision-and-goals.md](00-overview/01-vision-and-goals.md) → [00-overview/05-glossary.md](00-overview/05-glossary.md) → [01-game-design/01-core-gameplay.md](01-game-design/01-core-gameplay.md) → [00-overview/03-milestones.md](00-overview/03-milestones.md)
- **Chuẩn bị vẽ/gen ảnh**: [02-art/01-art-style-guide.md](02-art/01-art-style-guide.md) → [02-art/05-ai-image-pipeline.md](02-art/05-ai-image-pipeline.md) → [02-art/06-prompt-library.md](02-art/06-prompt-library.md) → file đặc tả tương ứng
- **Chuẩn bị code**: [05-technical/01-architecture.md](05-technical/01-architecture.md) → [05-technical/03-coding-standards.md](05-technical/03-coding-standards.md) → [05-technical/04-data-schemas.md](05-technical/04-data-schemas.md)
- **AI agent**: [/CLAUDE.md](../CLAUDE.md) → [07-ai/01-ai-collaboration.md](07-ai/01-ai-collaboration.md)

## Quy ước viết tài liệu

1. **Viết lý do, không chỉ kết luận.** Mỗi quy tắc quan trọng có dòng "Vì sao". Sau 6 tháng, người đọc phải hiểu được tại sao lại như vậy mà không cần hỏi ai.
2. **Tài liệu mô tả trạng thái hiện tại**, không phải lịch sử thay đổi. Không viết "trước đây là X, giờ đổi thành Y" trong thân tài liệu. Lịch sử và lý do đổi ghi ở [00-overview/04-decision-log.md](00-overview/04-decision-log.md).
3. **Số liệu có một nguồn duy nhất.** Ví dụ thông số vật lý chỉ định nghĩa trong [05-technical/05-physics-collision-generation.md](05-technical/05-physics-collision-generation.md); nơi khác chỉ trích dẫn/link tới, không chép lại số.
4. **Trạng thái của mỗi quyết định** được đánh dấu rõ:
   - `CHỐT` — chủ dự án đã xác nhận.
   - `ĐỀ XUẤT` — đề xuất hợp lý để bắt đầu, có thể đổi sau khi thử nghiệm/chủ dự án xem lại.
   - `MỞ` — câu hỏi chưa có câu trả lời, không được tự ý giả định.
5. **Tên trong tài liệu kỹ thuật trung lập với IP** (ví dụ `transform_item`, không phải `meat`). Tên One Piece chỉ xuất hiện trong phần nội dung (content pack) và ví dụ minh hoạ.
6. Khi thay đổi một quyết định: cập nhật tài liệu liên quan **và** thêm một mục vào decision log.
