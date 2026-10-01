# Âm thanh

## 1. Phong cách

**Chiptune** (âm thanh máy chơi game 8-bit/16-bit) để hợp với pixel art; mỗi đảo mang màu âm nhạc của vùng đó (Alabasta: âm giai Ả Rập; Wano: ngũ cung Nhật; Water 7: kiểu Venice). Hiệu ứng âm thanh ngắn, rõ, "giòn".

Vì sao chiptune: đồng bộ với hình ảnh; file nhẹ; công cụ tạo miễn phí và nhanh.

## 2. Cấu trúc kênh (bus) trong Godot

```
Master
├── Music        (nhạc nền)          ← cài đặt "Nhạc"
├── SFX          (hiệu ứng gameplay) ← cài đặt "Hiệu ứng"
│   └── SFX_Ducked (nhỏ lại khi có jingle)
├── UI           (nút, menu)         ← đi theo "Hiệu ứng"
└── Ambience     (môi trường)        ← đi theo "Nhạc"
```
- Khi phát jingle (biến hình, kỷ lục), nhạc nền giảm ~6 dB trong thời gian jingle (ducking).
- Giới hạn số âm cùng loại phát đồng thời (ví dụ xu: tối đa 3) để không bị ồn khi nhặt cả hàng xu.

## 3. Nhạc

| ID | Dùng ở | Mô tả | Vòng lặp |
|---|---|---|---|
| `music_menu` | Menu | Vui tươi, phiêu lưu, tempo vừa | ✔ |
| `music_island_<id>` | Mỗi đảo | Theo màu sắc vùng; dài 60–90 s | ✔ (có điểm loop) |
| `music_sea` | Đoạn biển | Nhẹ, lướt sóng, hải âu | ✔ |
| `music_event_<id>` | Sự kiện boss | Lớp trống/bass căng thêm vào nhạc đảo | ✔ (chồng lớp) |
| `jingle_new_record` | Kết quả | 2–3 s | ✘ |
| `jingle_gameover` | Chết | 1.5 s, hài hước không buồn | ✘ |
| `jingle_island_arrive` | Cập đảo mới | 2 s, hào hứng | ✘ |

**Nhạc theo lớp (đề xuất)**: nhạc đảo xuất thành 2 stem: `base` + `intensity` (trống mạnh hơn). Khi tốc độ vượt 70% khoảng tốc độ của đảo hoặc khi có sự kiện boss → bật dần stem `intensity`. Vì: nhạc "căng" theo gameplay mà không cần nhiều bài.

Chuyển nhạc đảo → biển: crossfade 1.5 s tại lúc nhân vật đặt chân lên tàu.

### Prompt nhạc (cho AI tạo nhạc kiểu Suno / Udio)
`music_island_alabasta`:
```
Instrumental chiptune, 8-bit NES-style sound chip (square waves, triangle bass, noise
percussion), Arabian desert adventure theme using a Phrygian dominant scale, energetic
running rhythm, 140 BPM, catchy lead melody, no vocals, seamless loop, about 80 seconds.
```
`music_sea`:
```
Instrumental chiptune, 8-bit sound chip, cheerful pirate sea adventure, sailing feeling,
light bouncy rhythm in 6/8, 120 BPM, bright lead melody, no vocals, seamless loop.
```
`music_menu`:
```
Instrumental chiptune, 8-bit sound chip, upbeat heroic adventure title theme, memorable short
motif, 128 BPM, no vocals, seamless loop, about 45 seconds.
```

Nhạc AI thường không lặp liền mạch → cắt điểm loop thủ công (mục 6).

## 4. Hiệu ứng âm thanh (SFX)

Mỗi dòng: mô tả để người làm hiểu + gợi ý thông số cho **sfxr / jsfxr / ChipTone** (công cụ tạo âm 8-bit miễn phí, chỉnh bằng thanh trượt) + prompt cho AI tạo âm thanh (kiểu ElevenLabs Sound Effects) nếu muốn.

| ID | Khi nào | Mô tả | sfxr gợi ý | Prompt AI |
|---|---|---|---|---|
| `sfx_jump` | Rời đất | "Bụp" nảy lên, cao độ đi lên, rất ngắn (0.15 s) | Preset *Jump* | `short 8-bit chiptune jump sound, quick rising square wave blip, 0.15 seconds` |
| `sfx_jump_high` | Giữ đủ lâu (nhảy cao) | Như trên nhưng thêm đuôi cao hơn | *Jump* + sustain dài hơn | `8-bit jump sound with a longer rising tail` |
| `sfx_double_jump` | Nhảy đôi | Hai nốt nhanh đi lên | *Jump* pitch cao hơn | `two quick rising 8-bit blips` |
| `sfx_land` | Chạm đất | "Thịch" nhẹ trầm | *Hit/Hurt* âm lượng thấp, noise | `soft 8-bit landing thud, low noise burst, very short` |
| `sfx_coin` | Nhặt xu | "Ting" hai nốt | Preset *Pickup/Coin* | `8-bit coin pickup sound, two bright ascending notes` |
| `sfx_item` | Nhặt item | Hợp âm rải đi lên | *Powerup* | `8-bit power-up pickup, fast ascending arpeggio` |
| `sfx_transform` | Biến hình | Arpeggio dài + noise "phừng" | *Powerup* dài + noise | `8-bit transformation sound, long rising arpeggio with a burst of noise at the end` |
| `sfx_shield_on` | Có khiên | "Bloop" tròn | *Blip* sine | `bubbly 8-bit bloop` |
| `sfx_shield_pop` | Vỡ khiên | "Bốp" bong bóng vỡ | *Explosion* rất ngắn, cao | `8-bit bubble pop` |
| `sfx_perfect` | Perfect Jump | "Ting!" sáng, có vang | *Pickup* cao + echo | `bright 8-bit sparkle ding, satisfying, short` |
| `sfx_combo_tier` | Lên mốc combo | Nốt cao dần theo mốc | *Blip*, đổi pitch theo mốc | — |
| `sfx_destroy` | Phá vật cản | "Rầm" vỡ vụn | *Explosion* ngắn | `8-bit crash and break sound, short` |
| `sfx_enemy_defeat` | Hạ kẻ địch | "Bốp" + kêu ngắn | *Hit* | `8-bit punch hit with a funny squeak` |
| `sfx_hit_death` | Va chạm chết | "Bịch" nặng + rơi | *Hit/Hurt* mạnh | `heavy 8-bit hit, descending pitch` |
| `sfx_fall` | Rơi xuống hố | Còi trượt xuống | *Laser* pitch đi xuống chậm | `8-bit falling whistle, descending slide` |
| `sfx_splash` | Rơi xuống nước | Noise toé | *Explosion* lọc cao | `8-bit water splash` |
| `sfx_warning` | Báo vật rơi/bay | "Bíp bíp" | *Blip* lặp 2 lần | `two short 8-bit warning beeps` |
| `sfx_cannon` | Đạn pháo bắn | "Bùm" xa | *Explosion* trầm, âm nhỏ | `distant 8-bit cannon boom` |
| `sfx_sand_blade` | Lưỡi cát | Noise "xèèè" quét | Noise dài có sweep | `8-bit sand whoosh sweeping` |
| `sfx_ui_tap` | Bấm nút | "Tách" ngắn | *Blip* | `8-bit menu click` |
| `sfx_ui_back` | Quay lại | "Tách" trầm | *Blip* thấp | — |
| `sfx_pause` | Pause | Hai nốt đi xuống | *Blip* | — |

## 5. Ambience (môi trường)

| ID | Đoạn | Mô tả |
|---|---|---|
| `amb_desert_wind` | Alabasta 1, 4 | Gió sa mạc, cát rít nhẹ |
| `amb_market` | Rainbase | Tiếng chợ lẫn, nhạc casino xa |
| `amb_ruins_wind` | Yuba | Gió hú |
| `amb_river` | Sandora | Nước chảy |
| `amb_battle` | Alubarna | Tiếng hô xa, kiếm, trống |
| `amb_sea` | Biển | Sóng, hải âu, gỗ tàu kẽo kẹt |

Ambience không cần chiptune thuần — có thể là âm thật đã lọc nhẹ (low-pass) và để nhỏ (-20 dB so với nhạc). Chuyển đoạn: crossfade 2 s.

## 6. Thông số kỹ thuật

| Loại | Định dạng | Thông số | Ghi chú |
|---|---|---|---|
| Nhạc, ambience | OGG Vorbis | 44.1 kHz, stereo, ~128 kbps | Bật *loop* trong import Godot; đặt `loop_offset` nếu có intro |
| SFX | WAV | 44.1 kHz, 16-bit, mono | Ngắn, không nén để phát tức thì |
| Độ to nhạc | ~-16 LUFS tích hợp | | Đồng đều giữa các bài |
| Đỉnh SFX | ≤ -3 dBFS | | Không vỡ tiếng khi chồng nhiều âm |

Xử lý sau khi gen: **Audacity** (miễn phí) — cắt khoảng lặng đầu/cuối, chuẩn hoá âm lượng, cắt điểm loop tại điểm giao 0 (zero crossing), fade 5 ms ở hai đầu SFX để không "lụp bụp".

Cấu trúc thư mục:
```
art-source/audio-raw/<loại>/<id>/...         (file gốc từ AI/sfxr + .prompt.md hoặc tham số sfxr .json)
game/content/<pack>/audio/music/*.ogg
game/content/<pack>/audio/sfx/*.wav
game/content/<pack>/audio/ambience/*.ogg
game/shared/audio/ui/*.wav                    (âm UI dùng chung mọi pack)
```
Lưu tham số sfxr (file .json mà jsfxr xuất được) để tạo lại/chỉnh sau.

## 7. Công cụ

| Công cụ | Dùng để | Phí |
|---|---|---|
| sfxr / jsfxr / ChipTone | SFX 8-bit | Miễn phí |
| BeepBox / JummBox | Soạn nhạc chiptune trên web | Miễn phí |
| FamiStudio | Soạn nhạc chuẩn chip NES | Miễn phí |
| Bosca Ceoil | Soạn nhạc đơn giản | Miễn phí |
| Suno / Udio | AI tạo nhạc theo prompt | Có bản miễn phí, có giới hạn |
| ElevenLabs Sound Effects | AI tạo SFX theo prompt | Có bản miễn phí, có giới hạn |
| Audacity | Cắt, chuẩn hoá, loop | Miễn phí |

## 8. Rung (haptics)

| Sự kiện | Rung |
|---|---|
| Chết | 1 lần, 60 ms, mạnh |
| Vỡ khiên | 1 lần, 30 ms |
| Biến hình | 2 lần ngắn |
| Perfect | 1 lần rất nhẹ, 10 ms |

Tắt được trong cài đặt; mặc định bật.

## 9. Âm thanh trong content pack

Âm gắn với IP (giọng nhân vật nếu có, jingle biến hình riêng) nằm trong content pack. Âm chung (UI, rơi, va chạm chung) nằm trong `shared`. Khi đổi pack, dữ liệu nhân vật trỏ tới âm của pack mới.
