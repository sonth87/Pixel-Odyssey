# Thuật ngữ

Dùng đúng thuật ngữ này trong tài liệu, code, và khi trao đổi với AI. Cột "Trong code" là tên dùng trong code (tiếng Anh, trung lập với IP).

## Cấu trúc trò chơi

| Thuật ngữ | Trong code | Nghĩa |
|---|---|---|
| Run (lượt chạy) | `Run` | Một lần chơi từ lúc bắt đầu tới lúc chết. Chết là hết run. |
| Hành trình | `Journey` | Danh sách đảo và đoạn biển theo thứ tự cố định mà một run đi qua. |
| Đảo | `Island` | Một địa danh (Alabasta, Water 7...). Gồm nhiều đoạn. |
| Đoạn biển | `SeaPassage` | Phần chạy trên tàu giữa hai đảo. Về kỹ thuật cũng là một `Island` có loại `sea`. |
| Đoạn | `Segment` | Một phần của đảo có bối cảnh cố định (sa mạc, thành phố...). Độ dài tính theo % đảo. |
| Chunk (mẫu đoạn) | `Chunk` | Một khúc đường ngắn (thường 1–3 màn hình) được thiết kế tay: vị trí chướng ngại vật, địa hình, điểm đặt item. Đoạn được lấp bằng chuỗi chunk chọn ngẫu nhiên. |
| Pool | `ChunkPool` | Danh sách chunk mà một đoạn được phép dùng, kèm trọng số và độ khó. |
| Content pack | `ContentPack` | Gói nội dung của một chủ đề: nhân vật, đảo, item, âm thanh, chữ. Ví dụ `onepiece`, `original`. |
| Seed | `seed` | Con số khởi tạo bộ ngẫu nhiên. Cùng seed → cùng chuỗi ngẫu nhiên. |

## Điều khiển & cảm giác chơi

| Thuật ngữ | Trong code | Nghĩa |
|---|---|---|
| Coyote time | `coyote_time` | Khoảng thời gian rất ngắn sau khi chạy khỏi mép vẫn được phép nhảy. Tên lấy từ phim hoạt hình chó sói chạy ra khỏi vực vẫn lơ lửng. Làm game "dễ chịu" hơn mà người chơi không nhận ra. |
| Jump buffer | `jump_buffer` | Nếu bấm nhảy hơi sớm (chưa chạm đất), game nhớ lệnh và nhảy ngay khi chạm đất. |
| Jump cut / giữ để nhảy cao | `hold_gravity_scale` | Trong lúc giữ, trọng lực giảm → bay cao hơn. Thả ra → trọng lực bình thường. |
| Perfect Jump | `perfect` | Vượt qua chướng ngại vật với khoảng hở rất nhỏ → thưởng. |
| Hitbox | `Hitbox` | Vùng **gây** va chạm (vật cản, đòn đánh). |
| Hurtbox | `Hurtbox` | Vùng **nhận** va chạm (thân nhân vật). Thường nhỏ hơn hình vẽ. |
| Game feel / juice | — | Các phản hồi nhỏ làm hành động "sướng": rung màn hình, hạt bụi, dừng hình vài frame, âm thanh. |
| Hit-stop | `hit_stop` | Dừng hình trong 2–5 frame khi có va chạm mạnh để nhấn mạnh. |
| Đạp (stomp) | `stomp` | Rơi từ trên xuống đầu kẻ địch đạp được → hạ nó và nảy lên. |
| i-frames | `i_frames` | Khoảng thời gian ngắn bất tử sau khi vỡ khiên / hết biến hình, nhân vật nhấp nháy. |
| Corner correction | `corner_correction` | Khi nhân vật chạm cạnh bậc mà chỉ thiếu vài pixel, game tự đẩy lên đứng trên bậc thay vì cho chết. |
| Lao tốc (rush) | `rush` | Trạng thái tăng tốc được bảo vệ toàn phần (va chạm, hố, tường). |
| Kích hoạt (trigger) | `trigger_distance` | Khoảng cách tới người chơi mà kẻ địch bắt đầu báo trước/hành động. |
| Báo trước (telegraph) | `telegraph` | Tín hiệu hình/âm cho biết mối nguy sắp xảy ra (bóng đổ, dấu "!", thu người lấy đà). |
| Thời gian phản ứng | — | Thời gian từ lúc mối nguy nhận biết được tới lúc nó chạm người chơi. Tối thiểu 0.70 s. |
| Tốc độ tiếp cận | — | Tốc độ người chơi + tốc độ riêng của vật lao về phía người chơi. Tối đa 365 px/s. |
| Ma trận tương tác | — | Bảng "loại vật × trạng thái người chơi → kết quả" — luật chơi chính thức khi va chạm. |
| Bất biến hiệu ứng | E1–E4 | Luật: mọi hiệu ứng chỉ được làm người chơi an toàn hơn trạng thái thường. |

## Animation

| Thuật ngữ | Trong code | Nghĩa |
|---|---|---|
| Frame | — | Một hình trong chuỗi animation. |
| FPS animation | `fps` | Số frame hiển thị mỗi giây của animation (khác FPS của game). Pixel art thường 8–12. |
| Loop | `loop` | Animation lặp lại (chạy, đứng) hay chạy một lần (nhảy lên, chết). |
| Pivot (tâm) | `pivot` | Điểm neo của sprite; nhân vật dùng điểm giữa chân. Mọi frame phải cùng pivot, nếu không nhân vật bị "rung". |
| Startup | `startup` | Pha chuẩn bị ra chiêu (lấy đà). Chưa gây sát thương. |
| Active | `active` | Pha chiêu có hiệu lực (vùng đánh đang bật). |
| Recovery | `recovery` | Pha thu chiêu, trở về tư thế bình thường. |
| Sprite sheet | — | Một ảnh chứa nhiều frame xếp lưới. |
| Onion skin | — | Tính năng của phần mềm vẽ (Pixelorama) hiện mờ frame trước/sau để vẽ animation mượt. |

## Đồ hoạ

| Thuật ngữ | Nghĩa |
|---|---|
| Lưới pixel / độ phân giải gốc | Kích thước thật của hình pixel art (ví dụ 64×64), trước khi phóng to. |
| Phóng to số nguyên | Phóng 2×, 3×, 4×... không bao giờ 2.5× (sẽ làm pixel méo không đều). |
| Nearest (lọc gần nhất) | Kiểu phóng ảnh giữ cạnh pixel sắc. Ngược lại là Linear làm nhoè. |
| Pixel giả | Ảnh AI vẽ "trông như pixel art" nhưng ô pixel không đều, có viền mờ, màu lẫn nhau. Phải xử lý mới dùng được. |
| Bảng màu (palette) | Danh sách màu giới hạn được dùng. Giữ cho mọi hình đồng bộ. |
| Parallax | Các lớp nền trôi với tốc độ khác nhau → tạo chiều sâu. Lớp xa trôi chậm, lớp gần trôi nhanh. |
| Tileable / liền mạch | Hình ghép nối tiếp nhau không lộ đường nối. |
| Greybox | Bản thử nghiệm dùng khối màu xám thay cho art thật. |

## Kỹ thuật

| Thuật ngữ | Nghĩa |
|---|---|
| Resource (Godot) | File dữ liệu `.tres` có kiểu, dùng để mô tả nhân vật, item, đảo... Không chứa logic. |
| Scene (Godot) | File `.tscn`, một cây node có thể dùng lại (nhân vật, chunk, UI...). |
| Autoload | Node toàn cục Godot nạp sẵn. Dùng rất hạn chế. |
| Signal | Cơ chế Godot để một node báo sự kiện cho node khác mà không cần biết nhau. |
| Event bus | Một autoload chứa các signal dùng chung cho sự kiện giữa các hệ thống. |
| Object pool | Tạo sẵn object và tái sử dụng thay vì tạo/huỷ liên tục. |
| Tất định (deterministic) | Cùng đầu vào → cùng kết quả. |
| Validator | Công cụ tự động kiểm tra dữ liệu (ví dụ chunk có vượt qua được không). |
| Vertical slice | Một lát cắt nhỏ nhưng **hoàn chỉnh như thành phẩm** (art, âm thanh, gameplay) để chứng minh công thức. |
| God file / god function | File/hàm làm quá nhiều việc, khó sửa, khó test. Cấm. |
