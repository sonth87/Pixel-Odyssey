# Tầm nhìn, mong muốn và định hướng phát triển

## 1. Mô tả ngắn

Một game **endless runner một nút bấm**, đồ hoạ **pixel art độ phân giải thấp**, màn hình ngang. Nhân vật tự chạy từ trái sang phải; người chơi chỉ **chạm (tap) để nhảy**, giữ lâu hơn để nhảy cao hơn. Trên đường chạy có chướng ngại vật, kẻ địch, item. Ăn item để có năng lực tạm thời (khiên, biến hình, năng lực trái ác quỷ...). Chết là **chơi lại từ đầu**. Mục tiêu: **đi xa nhất có thể trong một lần chạy**.

Nội dung đầu tiên (content pack đầu tiên) lấy bối cảnh **One Piece**: nhân vật chạy xuyên qua các hòn đảo theo đúng thứ tự trong truyện (East Blue → ... → Alabasta → Water 7 → ... → Wano...), giữa các đảo là đoạn chạy trên tàu. Mỗi đảo có cảnh nền, người dân, chướng ngại vật và "sự kiện boss" riêng — boss **không đánh nhau trực tiếp**, chỉ xuất hiện ở nền hoặc dưới dạng một chuỗi chướng ngại vật đặc biệt.

Cảm giác mong muốn:
- *"Chơi 10 giây cũng được, chơi 20 phút để phá kỷ lục cũng được."*
- *"Chết rồi, chơi lại phát nữa."*
- *"Mình đang thực sự chạy xuyên qua thế giới One Piece."*

## 2. Mong muốn của chủ dự án

| # | Mong muốn | Hệ quả thiết kế |
|---|---|---|
| W1 | Gameplay đơn giản như Flappy Bird / khủng long Chrome — chỉ một thao tác | Không thêm nút tấn công, joystick. Mọi chiều sâu phải đến từ *thời điểm* và *độ dài* chạm. |
| W2 | Có cảm giác One Piece mạnh: nhân vật, đảo, item, boss | Fan-service đi qua **hình ảnh, môi trường, item**, không qua hệ thống chiến đấu phức tạp. |
| W3 | Điểm số có ý nghĩa cạnh tranh giữa người chơi | Chết = reset toàn bộ run, không hồi sinh, không checkpoint. |
| W4 | Màn cuối phải khó tới, cần kỹ năng thật | Tiến trình qua đảo là tiến trình **kỹ năng của người chơi**, không phải mở khoá bằng cày. |
| W5 | Mỗi lần chơi phải khác nhau nhưng luôn công bằng (vượt qua được) | Cấu trúc đảo/đoạn cố định, chướng ngại vật **ngẫu nhiên có kiểm soát** từ các mẫu đã kiểm định. |
| W6 | Chấp nhận may rủi về item — tạo tâm lý muốn chơi tiếp | Item ngẫu nhiên có giới hạn số lượng, không cần công bằng tuyệt đối. |
| W7 | Có thể đổi toàn bộ bối cảnh/nhân vật/item sang chủ đề khác (nhân vật tự xây dựng, hoặc chủ đề khác) mà **logic giữ nguyên** | Tách **engine/gameplay** khỏi **content pack**. Code không được biết "Luffy" là ai. |
| W8 | Tái sử dụng art, nhân vật, bối cảnh, một phần kỹ thuật cho **game thứ 2** (lối chơi kiểu Ninja School) | Tách lớp `shared` (dùng chung) khỏi lớp `runner` (riêng game 1). Animation nhân vật vẽ theo chuẩn dùng được cho game hành động. |
| W9 | Phạm vi đủ lớn để game hấp dẫn, nhưng làm theo milestone | Tầm nhìn lớn nằm trong roadmap; mỗi milestone phải ra được một bản **chơi được**. |
| W10 | Code sạch, dễ mở rộng, không god file/god function, không comment thừa | Quy tắc code chi tiết ở [05-technical/03-coding-standards.md](../05-technical/03-coding-standards.md). |
| W11 | Mọi thứ phải được ghi lại để không quên quy tắc | Bộ tài liệu này + decision log + skill quy trình cho AI. |

## 3. Hai game, một nền tảng

```
                 SHARED (dùng chung)
   art nhân vật · animation chuẩn hoá · dữ liệu nhân vật/skill
   âm thanh · ngôn ngữ · tiện ích kỹ thuật (state machine, save,
   settings, audio, RNG có seed, object pool, event bus)
                 │                         │
        GAME 1: RUNNER              GAME 2: ACTION (sau này)
   chạy tự động, 1 nút,         kiểu Ninja School: di chuyển tự do,
   chướng ngại vật, điểm        đánh nhau, skill, chỉ số, bản đồ
```

- **Game 1 (dự án này)**: endless runner. Đây là game làm trước.
- **Game 2 (chưa bắt đầu)**: cùng thế giới, nhân vật, art; lối chơi hành động kiểu Ninja School (combat, damage, crit, chỉ số...).
- **Nguyên tắc chia sẻ**: chia sẻ **nội dung và tiện ích**, **không** chia sẻ hệ thống gameplay. Vật lý nhảy của runner và hệ thống combat của game hành động khác nhau đến mức ép dùng chung sẽ làm hỏng cả hai. Chi tiết: [05-technical/07-reuse-for-game-2.md](../05-technical/07-reuse-for-game-2.md).

## 4. Trụ cột thiết kế (design pillars)

Khi phải chọn giữa hai phương án, dùng các trụ cột này theo thứ tự ưu tiên:

1. **Một nút, phản hồi tức thì.** Mọi thứ phục vụ cảm giác nhảy "đã tay". Nếu một tính năng làm điều khiển phức tạp hơn → loại.
2. **Luôn công bằng về khả năng vượt qua.** Người chơi chết phải thấy là lỗi của mình. Không bao giờ có đoạn không thể vượt qua.
3. **Thế giới kể chuyện bằng hình ảnh.** Không hội thoại, không cutscene dài. Cảnh nền, NPC, sự kiện nền làm thay.
4. **Thử lại tức thì.** Từ lúc chết đến lúc chạy lại ≤ 1 chạm và ≤ 1 giây.
5. **Dữ liệu thay vì code.** Thêm nhân vật/đảo/item = thêm dữ liệu + asset, không sửa code gameplay.

## 5. Không làm (non-goals) trong game 1

- Không có nút tấn công, không có combat chủ động.
- Không có damage, máu, crit, chỉ số kiểu RPG (dành cho game 2).
- Không có hồi sinh trong cùng một run (kể cả trả tiền/xem quảng cáo) — vì phá vỡ W3. Trạng thái: `CHỐT` theo yêu cầu "chết là bắt đầu lại từ đầu".
- Không có hội thoại/cốt truyện dạng chữ trong lúc chạy.
- Không có level editor cho người chơi.
- Chủ đề bản quyền tạm thời **không bàn** (quyết định của chủ dự án), nhưng kiến trúc content pack vẫn đảm bảo có thể thay toàn bộ nội dung.

## 6. Định hướng phát triển dài hạn

| Giai đoạn | Nội dung |
|---|---|
| Ngắn hạn | Nền tảng kỹ thuật + cảm giác chơi + 1 nhân vật (Luffy) + 1 đảo hoàn chỉnh (Alabasta) — xem milestone M0–M4 |
| Trung hạn | Thêm nhân vật Băng Mũ Rơm, thêm đảo theo thứ tự truyện, hệ trái ác quỷ, meta (Berries, nâng cấp, mở khoá), bảng xếp hạng — M5–M7 |
| Phát hành | Tối ưu mobile, xuất bản Android/iOS — M8 |
| Dài hạn | Content pack thứ 2 (nhân vật tự xây dựng); bắt đầu game 2 trên lớp `shared` |

Chi tiết từng milestone: [03-milestones.md](03-milestones.md).

## 7. Đối tượng và nền tảng

- **Nền tảng chính**: điện thoại (Android, iOS), màn hình ngang. `ĐỀ XUẤT`
- **Nền tảng phụ**: PC (để phát triển và test nhanh), có thể Web. `ĐỀ XUẤT`
- **Người chơi**: xem [06-user/01-player-experience.md](../06-user/01-player-experience.md).

## 8. Công nghệ

- **Engine**: Godot 4 (bản stable mới nhất tại thời điểm bắt đầu M0, khoá phiên bản trong decision log). `ĐỀ XUẤT` — lý do: 2D pixel art rất tốt, nhẹ, miễn phí, hệ Resource phù hợp thiết kế hướng dữ liệu, có sẵn node Parallax2D.
- **Ngôn ngữ**: GDScript có khai báo kiểu tĩnh (static typing).
- **Art**: AI gen ảnh (Gemini / ChatGPT) → script chuyển thành pixel art thật → chỉnh sửa và làm animation trong Aseprite → import Godot. Chi tiết: [02-art/05-ai-image-pipeline.md](../02-art/05-ai-image-pipeline.md).
- **Âm thanh**: chiptune; công cụ ở [03-audio/01-audio-spec.md](../03-audio/01-audio-spec.md).
