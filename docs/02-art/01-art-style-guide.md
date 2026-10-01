# Chuẩn phong cách hình ảnh (Art style guide)

Chuẩn này được **đo trực tiếp** từ ảnh tham khảo trong `assets/charactors/` (D-009). Mọi asset — nhân vật, nền, chướng ngại vật, item, VFX — phải tuân theo. 3 ảnh `assets/1.jpg`, `2.jpg`, `3.jpg` chỉ minh hoạ *ý tưởng bố cục nền*, **không** phải chuẩn phong cách.

## 1. Phong cách là gì

**Pixel art độ phân giải thấp, chibi, tô phẳng, không viền đen**, bảng màu dịu hơi ấm.

Ảnh tham khảo là pixel art **thật**: nhân vật được vẽ trên lưới 64×64 pixel rồi phóng to 16× (ảnh 1024 px) hoặc 22.5× (ảnh 1440 px) để xem. Khi đưa vào game, ta dùng **kích thước gốc** (64×64), engine tự phóng to bằng số nguyên.

Về tên gọi: phong cách này thường được gọi chung là "8-bit" — đúng theo nghĩa phổ thông (độ phân giải thấp, khối pixel to, ít màu). Khác với 8-bit "gốc" của máy NES ở chỗ bảng màu rộng hơn (NES chỉ cho ~3 màu/sprite). Trong tài liệu dùng từ "pixel art" để tránh nhầm.

## 2. Số đo chuẩn

| Thuộc tính | Giá trị | Ghi chú |
|---|---|---|
| Khung frame nhân vật chuẩn | **64×64 px** | Đo từ ảnh tham khảo |
| Chiều cao nhân vật (đứng) | **22–24 px** | Luffy ~23 px tính cả mũ; Chopper thấp hơn (~16 px) |
| Chiều rộng thân | 12–16 px | Không tính vũ khí/tay vươn |
| Tỉ lệ đầu/thân | Đầu ≈ 40% chiều cao (~9–10 px) | Chibi ~2.3 đầu |
| Mắt | Khối 2×2 hoặc 2×1 px màu đen/xám đậm, có thể 1 px trắng | |
| Viền | **Không có viền đen**. Cạnh hình xác định bằng sắc độ đậm hơn của chính màu đó | Rất quan trọng để giữ phong cách |
| Tô bóng | Phẳng, 2–3 sắc độ / chất liệu: màu gốc, bóng, (điểm sáng nhỏ) | Không gradient, không dither |
| Số màu / nhân vật | ~10–16 màu | |
| Ánh sáng | Từ trên, hơi chếch trước; bóng đổ về phía dưới và phía sau | |
| Pixel | Mọi pixel vuông, cùng kích thước, đúng lưới; alpha chỉ 0 hoặc 255 | Không có pixel bán trong suốt |

### Khung frame mở rộng

| Loại | Khung | Pivot (tâm neo) | Dùng cho |
|---|---|---|---|
| Chuẩn | 64×64 | (32, 64) — giữa đáy | Mọi trạng thái thường |
| Rộng | 128×64 | (64, 64) | Đòn vươn xa (tay Luffy, chém Zoro) |
| Lớn | 96×96 | (48, 96) | Dạng biến hình to (Gear 4, Chopper Monster Point) |
| Rất lớn | 128×128 | (64, 128) | Dạng khổng lồ (Franky Shogun) |

**Pivot là điểm giữa hai chân, sát đáy khung**. Mọi frame của một nhân vật phải đặt chân đúng hàng pixel đáy và thân đúng giữa — nếu lệch 1 px, nhân vật sẽ "rung" khi chạy animation.

### Hướng nhìn
- Game 1: nhân vật luôn **nhìn sang phải** (góc nghiêng 3/4 hướng phải, giống ảnh tham khảo nhưng quay phải).
- Vẽ hướng phải; engine lật ngang khi cần (game 2). Chấp nhận chi tiết bất đối xứng bị lật (vết sẹo, kiếm) — ở 24 px không đáng kể.

## 3. Bảng màu

Màu đo từ ảnh tham khảo (đã làm tròn). File chuẩn `art-source/palettes/master.gpl` được tạo ở M0 bằng script từ toàn bộ ảnh tham khảo; danh sách dưới đây là điểm tham chiếu.

| Nhóm | Màu |
|---|---|
| Nền xem trước (không dùng trong game) | `#FCF5EA` |
| Vạch mặt đất ảnh tham khảo | `#E4DCD1` |
| Da (sáng / gốc / bóng / bóng đậm) | `#F0E0C8` `#EADAC0` `#D0BF9C` `#C9AD87` |
| Tóc đen / mắt | `#222124` `#090909` `#464450` |
| Đỏ (áo Luffy, mũ Chopper) | `#90191C` `#771516` `#5E1012` |
| Rơm (mũ Luffy) | `#E2C397` `#C9AD87` `#AC906A` `#927755` |
| Xanh quần Luffy | `#5571A3` `#3F5C8B` `#224D6C` |
| Xanh lá (tóc Zoro) | `#9DD479` `#8BBA6A` `#77A05A` `#64854C` |
| Trắng xanh (áo Zoro, sọc Nami) | `#E7E8FC` `#DBDCEF` `#CFD0E2` |
| Đen than (quần Zoro, vest Sanji) | `#39383D` `#212123` `#151513` |
| Xám kim loại (kiếm) | `#B7B5B8` `#646466` |
| Cam (tóc Nami) | `#FFA001` `#ED8301` `#D37500` `#BB6700` `#A15900` |
| Xanh dương sọc Nami | `#01529F` |
| Vàng (tóc Sanji) | `#D4B830` (ước lượng) |

Quy tắc bảng màu:
- Nhân vật: mỗi nhân vật một bảng con `art-source/palettes/characters/<id>.gpl` (≤16 màu), rút từ master.
- Nền: mỗi đoạn một bảng con ≤ 24 màu. Lớp càng xa càng **ít tương phản**, ngả về màu trời (phối cảnh khí quyển).
- **Gameplay phải nổi hơn nền**: chướng ngại vật và nhân vật có tương phản cao hơn nền gần; nền xa nhạt/mờ (bằng màu, không bằng alpha).

## 4. Mật độ pixel thống nhất

**Quy tắc vàng**: 1 pixel của asset = 1 pixel logic của màn hình 320×180. Không có asset nào được vẽ ở mật độ khác rồi thu nhỏ/phóng to không nguyên lần (NFR-VS-01, NFR-VS-02).

Hệ quả cho nền: nền phải **đơn giản như nhân vật** — khối phẳng, ít chi tiết. Một ngôi nhà ở nền giữa có thể chỉ 30×24 px với 4–5 màu. Không vẽ nền chi tiết kiểu ảnh `2.jpg`.

Hệ quả cho vật ở xa: muốn vật trông xa → **vẽ nhỏ hơn** (NPC nền cao 12–16 px) + màu nhạt hơn, **không** thu nhỏ hình to.

Ngoại lệ duy nhất: UI vẽ ở lưới 640×360 (D-017).

## 5. Bố cục màn hình (lưới 320×180)

```
y=0   ┌────────────────────────────────────────────┐
      │  trời (L0)                                  │
      │        núi/xa (L1)       mây                │
y≈90  │   ┄┄┄ vùng vật cản trên không (air) ┄┄┄     │
      │      nhà / cây (L2–L4)                      │
y=124 │   [nhân vật 24px]                           │
y=148 ├══ mặt đất (gameplay) ═══════════════════════┤
      │  đất (2 hàng tile 16px)                     │
y=158 │  ··· vùng tiền cảnh được phép (L6) ···      │
y=180 └────────────────────────────────────────────┘
      x=64: vị trí nhân vật
```
Số liệu chính xác: [physics](../05-technical/05-physics-collision-generation.md).

## 6. Đọc được ở kích thước thật

Kiểm tra mọi asset ở **1× và 4×**:
- Ở 1×: hình dáng (silhouette) phải nhận ra ngay là vật gì, thuộc loại chướng ngại nào.
- Nhân vật phải tách khỏi nền ở mọi đoạn (thử đặt lên nền của cả 5 đoạn Alabasta).
- Chướng ngại vật nguy hiểm có điểm nhấn màu "nóng" hoặc tương phản; vật trang trí thì không.

## 7. Animation

- FPS animation 8–12 (chạy 12, đứng 6). Tốc độ chạy animation co giãn theo tốc độ chạy thật.
- Ưu tiên **ít frame, tư thế rõ** hơn là nhiều frame mượt.
- Khoảnh khắc mạnh (đáp đất, biến hình) dùng frame "squash & stretch" nhẹ (lún 1–2 px).

Đặc tả từng trạng thái: [character animation spec](02-character-animation-spec.md).

## 8. Không được làm

- Viền đen quanh nhân vật/vật.
- Gradient, anti-aliasing, blur, glow mềm, dither (trừ hiệu ứng đặc biệt có chủ đích, phải ghi vào decision log).
- Pixel bán trong suốt.
- Xoay sprite theo góc lẻ trong engine (làm méo lưới pixel) — muốn xoay thì vẽ frame riêng.
- Phóng to/thu nhỏ sprite không nguyên lần trong engine (trừ hiệu ứng ngắn ≤ 0.2 s như "pop").
