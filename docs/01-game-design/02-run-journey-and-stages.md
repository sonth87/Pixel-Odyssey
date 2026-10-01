# Run, hành trình, đảo, đoạn, chunk

## 1. Cấu trúc

```
RUN (một lần chơi, seed riêng)
└── JOURNEY (thứ tự cố định)
    ├── Island: Alabasta
    │   ├── Segment 1  (0–20%)   bối cảnh cố định
    │   │   └── chunk, chunk, chunk ...   ← chọn ngẫu nhiên từ pool của segment
    │   ├── Segment 2  (20–40%)
    │   ├── ...
    │   └── Exit: mép đất → tàu
    ├── SeaPassage: Going Merry (20–30 s)
    ├── Island: (đảo tiếp theo)
    └── ...
```

| Cấp | Cố định hay ngẫu nhiên | Ai quyết định |
|---|---|---|
| Thứ tự đảo | Cố định | Content pack (dữ liệu `Journey`) |
| Độ dài đảo, số đoạn, % mỗi đoạn | Cố định | Dữ liệu `Island` |
| Bối cảnh (nền, NPC, nhạc) của đoạn | Cố định | Dữ liệu `Segment` |
| Chuỗi chunk trong đoạn | **Ngẫu nhiên có kiểm soát** | `ChunkSpawner` dùng RNG của run |
| Item trong chunk | **Ngẫu nhiên có giới hạn** | `ItemSpawner` dùng luồng RNG riêng |
| NPC nền, mây, trang trí | Ngẫu nhiên (thuần trang trí) | Luồng RNG trang trí, không ảnh hưởng gameplay |

Vì sao cấu trúc này: người chơi luôn biết mình đang ở đâu trên hành trình (cảm giác tiến bộ), nhưng không thể học thuộc lòng chướng ngại vật (mỗi lần chơi khác nhau). Quyết định D-003, D-004.

## 2. Hành trình (content pack One Piece)

Thứ tự theo truyện, rút gọn để mỗi đảo đủ khác biệt về hình ảnh. Cột "Đoạn" là đề xuất ban đầu.

| # | Đảo / đoạn biển | Đoạn (segment) đề xuất | Sự kiện boss (nền / mẫu đặc biệt) | MS |
|---|---|---|---|---|
| 1 | Làng Foosha (East Blue) | bờ biển · làng · cối xay gió | — (đảo hướng dẫn, dễ) | M6 |
| 2 | Shells Town | phố cảng · căn cứ Marine | Morgan ở nền | M6 |
| 3 | Orange Town | phố bỏ hoang · quán rượu | Đầu Buggy rơi từ trời (mẫu `falling`) | M6 |
| 4 | Nhà hàng Baratie (biển) | sàn nhà hàng nổi | Don Krieg ở xa | M6 |
| 5 | Arlong Park / Cocoyasi | làng quýt · công viên Arlong | Arlong ở nền, nước bắn | M6 |
| 6 | Loguetown | phố đông · quảng trường đoạn đầu đài | Smoker, khói trắng ở nền | M6 |
| 7 | Reverse Mountain (biển) | dòng nước chảy ngược lên núi | Laboon ở nền | M6 |
| 8 | Little Garden / Drum | rừng khủng long · đảo tuyết | Núi lửa phun ở nền | M6 |
| 9 | **Alabasta** | sa mạc · Rainbase · Yuba · sông Sandora · Alubarna | Crocodile ở nền + lưỡi cát | **M3** |
| 10 | Jaya / Skypiea | thị trấn Mock · đảo mây | Sét của Enel (mẫu `falling`) | M6 |
| 11 | Water 7 | kênh đào · xưởng đóng tàu · ga Sea Train | Aqua Laguna (sóng lớn ở nền) | M6+ |
| 12 | Enies Lobby | cầu · toà án · tháp | CP9 ở nền, Buster Call | sau M6 |
| 13 | Thriller Bark | nghĩa địa · lâu đài | Bóng ma, zombie | sau M6 |
| 14 | Sabaody | rừng cây bong bóng · khu đấu giá | Pacifista, Kizaru ánh sáng | sau M6 |
| 15 | Marineford | quảng trường chiến tranh | Vụ nổ xa, băng, dung nham | sau M6 |
| 16 | Dressrosa | đấu trường · phố đồ chơi | Lồng chim (dây ngang màn hình) | sau M6 |
| 17 | Wano | làng · thủ đô Hana · Onigashima | Mây đen, sét, **bóng rồng hiện khi chớp** | sau M6 |
| 18 | Egghead | thành phố tương lai | Pacifista, robot ở nền | sau M6 |

Bảng trên là **toàn bộ tầm nhìn**. Không làm hết 18 đảo trước khi phát hành — mỗi đảo tốn ước tính 100–150 giờ sản xuất nếu làm như Alabasta (con số đo lại sau M3).

### 2.1 Hành trình phát hành — `ĐỀ XUẤT` cho Q-06 (chưa chốt)

| # | Đảo | Dài | Ghi chú |
|---|---|---|---|
| 1 | Làng Foosha | 800 m | Đảo hướng dẫn, ngắn |
| 2 | Orange Town | 1.000 m | Gộp nội dung Shells Town (lính Marine) |
| 3 | Baratie | 1.000 m | Đảo-trên-biển, nhiều sàn tàu |
| 4 | Arlong Park | 1.200 m | |
| 5 | Loguetown | 1.200 m | Kết thúc East Blue |
| 6 | Alabasta | 2.000 m | Đảo lớn, cao trào |
| — | **Vòng lặp** | | Sau Alabasta quay lại đảo 1 ở bậc khó cao hơn (tốc độ giữ 300 px/s, chunk độ khó cao hơn, bảng màu "hoàng hôn/đêm"), lặp tới khi chết |

- Tổng ~11 phút nếu không chết (tốc độ từng đảo: [physics §3.3](../05-technical/05-physics-collision-generation.md#33-bảng-tốc-độ--hành-trình-phát-hành-đề-xuất)) — khớp mục tiêu "người giỏi chơi 10–20 phút".
- Đảo mới thêm sau qua cập nhật, chèn vào trước vòng lặp.

### 2.2 Vấn đề lặp lại đầu hành trình
Chết là về đảo 1 (D-002), nên người chơi giỏi phải chạy lại nhiều lần những đảo đầu dễ. Cách giảm mệt (không phá luật chết là về đầu):
- **Đảo đầu ngắn** (800–1.000 m) và tăng độ khó nhanh hơn các đảo sau.
- Đảo đầu vẫn có chunk khó ở cuối, để người giỏi có việc để làm (Perfect, đạp, combo).
- Đảo hướng dẫn chỉ dạy ở lần chơi đầu; các lần sau dùng pool chunk thường.
- Không có "bắt đầu từ đảo xa" — phá giá trị bảng xếp hạng.

**Trong giai đoạn M3–M5**, khi các đảo trước chưa có, run bắt đầu ở Alabasta (cấu hình `Journey` tạm thời). Đây là cấu hình dữ liệu, không phải logic riêng.

## 3. Đảo (Island)

Mỗi đảo định nghĩa:
- **Độ dài** (m). Đề xuất 800–2.000 m tuỳ đảo (≈ 1.5–2.5 phút).
- **Danh sách đoạn** và % độ dài mỗi đoạn (tổng = 100%).
- **Tốc độ đầu và tốc độ cuối** của đảo; trong đảo tăng tuyến tính ([physics §3](../05-technical/05-physics-collision-generation.md#3-tốc-độ-chạy)).
- **Lối vào** (cập bờ từ tàu) và **lối ra** (mép đất → tàu).
- **Nhạc** của đảo.
- **Giới hạn item** (ví dụ tối đa 2 trái ác quỷ cả đảo).

## 4. Đoạn (Segment)

Mỗi đoạn định nghĩa:
- **Bối cảnh**: các lớp parallax, mặt đất (tileset), lớp tiền cảnh.
- **NPC nền**: danh sách + mật độ (thưa/vừa/đông).
- **Chunk pool**: danh sách chunk được phép, trọng số, khoảng độ khó.
- **Sự kiện** (tuỳ chọn): sự kiện nền hoặc mẫu đặc biệt, kích hoạt tại % nhất định của đoạn.
- **Ambience** (âm thanh môi trường).
- **Mảnh chuyển tiếp**: hình ở mỗi lớp parallax dùng để nối bối cảnh đoạn trước sang đoạn này (ví dụ cát thưa dần, nhà xuất hiện dần). Vì: nếu nền đổi "cái rụp" ở ranh giới đoạn sẽ rất giả.

## 5. Chunk

**Chunk** là đơn vị thiết kế nhỏ nhất của đường chạy: một khúc dài **1–3 màn hình** (320–960 px logic), thiết kế tay trong Godot như một scene.

Chunk chứa:
- **Địa hình**: mặt đất, hố, bậc.
- **Chướng ngại vật/kẻ địch**: vị trí đặt (marker) + loại; có thể chỉ định cụ thể hoặc "bất kỳ vật thấp nào trong bộ của đoạn" (để một chunk dùng được cho nhiều đảo). Kẻ địch có hành vi kích hoạt **theo vị trí người chơi** ([obstacles/enemies §2](08-obstacles-enemies-npc.md#2-vòng-đời-của-một-chướng-ngại-vật--kẻ-địch)).
- **Điểm đặt item**: vị trí + nhãn `safe` / `risky` + loại item cho phép.
- **Siêu dữ liệu**: độ khó 1–5, tốc độ min/max được phép dùng, chiều cao mặt đất ở đầu và cuối chunk (để nối khớp), thẻ (`intro`, `breather`, `air_heavy`...).

### 5.1 Chọn chunk khi chạy

Quy tắc của `ChunkSpawner` (`ĐỀ XUẤT`, chỉnh sau test):
1. Lọc pool của đoạn hiện tại theo: **tốc độ gốc** (không tính hiệu ứng) tại vị trí đầu chunk nằm trong khoảng cho phép của chunk; độ cao mặt đất đầu chunk khớp cuối chunk trước. Vì: chuỗi chunk phải chỉ phụ thuộc (seed, quãng đường), không phụ thuộc việc người chơi ăn item gì (D-021).
2. Lọc theo độ khó mục tiêu của vị trí hiện tại (đường cong độ khó — [difficulty](06-difficulty-and-pacing.md)).
3. Không lặp lại chunk vừa dùng trong 3 lượt gần nhất.
4. Sau 2 chunk độ khó ≥ 4 bắt buộc 1 chunk `breather` (nghỉ). Vì: nhịp căng – chùng tạo cảm giác "suýt chết" mà không mệt.
5. Chọn ngẫu nhiên theo trọng số bằng **luồng RNG chunk** của run.
6. Nếu chunk sẽ vượt qua ranh giới đoạn: được phép (chunk thuộc đoạn nơi nó **bắt đầu**); nền chuyển theo vị trí, không theo chunk.

### 5.2 Đảm bảo vượt qua được

Hai lớp bảo vệ:
1. **Lúc thiết kế**: validator mô phỏng nhân vật nhảy ở các tốc độ trong khoảng cho phép, chứng minh tồn tại ít nhất một chuỗi thao tác vượt qua chunk. Chunk không qua validator thì không được đưa vào pool. Chi tiết thuật toán: [physics](../05-technical/05-physics-collision-generation.md).
2. **Lúc nối chunk**: cuối mỗi chunk và đầu chunk sau có **vùng đệm** an toàn tối thiểu (đủ để đáp đất và nhảy lại), đảm bảo hai chunk hợp lệ ghép lại vẫn hợp lệ.

Ví dụ những thứ **cấm**: hố rộng hơn tầm nhảy xa nhất ở tốc độ đó; vật cao hơn tầm nhảy cao nhất; hai vật cản sát nhau tới mức không kịp đáp và nhảy lại; vật trên không đặt đúng chỗ bắt buộc phải nhảy cao.

## 6. Chuyển đảo ↔ biển

```
... đoạn cuối đảo ── mép đất ── [khoảng nước] ── tàu Going Merry ── đoạn biển ── cập đảo mới ...
```

- Cuối đảo có **chunk lối ra** cố định: mép đất, tàu neo cách một khoảng nhảy được (bằng nhảy chạm ở tốc độ hiện tại, có dư).
- Nhảy hụt = rơi xuống nước = chết. Vì: giữ tính liền mạch, không cắt cảnh — đây là "signature" của game.
- Đoạn biển là một `Island` loại `sea`: mặt đất là sàn tàu, chunk pool riêng (thùng, cột buồm, đạn pháo từ tàu Marine, sóng đánh lên sàn).
- Nền biển: trời, biển xa, tàu khác, Sea King thỉnh thoảng nhô lên (trang trí).
- Cuối đoạn biển: đảo mới hiện dần ở nền → tàu cập bờ → **chunk lối vào** cố định của đảo mới (nhảy từ tàu lên bờ, dễ).
- Tàu: Going Merry trước Water 7, Thousand Sunny sau Sabaody (dữ liệu của `SeaPassage`).

## 7. Sự kiện boss

Hai loại, đều **không có chiến đấu** (FR-WD-07):

| Loại | Code | Mô tả | Ảnh hưởng gameplay |
|---|---|---|---|
| Sự kiện nền | `BackgroundEvent` | Hình ảnh ở lớp parallax xa/giữa: bóng boss, hiệu ứng thời tiết, ánh sáng | **Không** |
| Mẫu đặc biệt | `HazardPattern` | Chuỗi chướng ngại vật kịch bản sẵn trong một khoảng ngắn (10–20 s), gắn với boss | Có — nhưng cũng là chunk đặc biệt và cũng phải qua validator |

Ví dụ Wano (sự kiện nền): mây đen kéo đến → ánh sáng tối dần → gió (hạt bụi bay ngang) → chớp sáng 2–3 frame → **bóng rồng** hiện ở lớp xa nhất trong đúng lúc chớp → trở lại bình thường. Người chơi: "Ủa vừa có cái gì vậy?". Với tuỳ chọn giảm nhấp nháy: chớp thay bằng đổi tông màu nhẹ, bóng rồng hiện mờ dần.

Ví dụ Alabasta (cả hai): Crocodile đứng trên mái casino Rainbase ở nền (nền) + "lưỡi cát" quét dọc mặt đất từ phải sang (mẫu đặc biệt) — có cảnh báo cát xoáy 1 s trước khi tới.

Quy tắc an toàn: sự kiện nền không được làm tối/che màn hình tới mức không nhìn rõ chướng ngại vật (độ tối tối đa 40%).
