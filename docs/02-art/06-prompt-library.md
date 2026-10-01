# Thư viện prompt

Prompt viết bằng **tiếng Anh** vì các model tạo ảnh (Gemini / ChatGPT) hiểu chính xác hơn. Mô tả tiếng Việt nằm ở các file đặc tả.

## 1. Cách ghép prompt

Mỗi prompt = ghép các **khối** theo thứ tự:

```
[STYLE]  +  [SUBJECT: nhân vật / vật / cảnh]  +  [POSE hoặc CONTENT]  +  [OUTPUT]  +  [AVOID]
```

- Khối có mã (ví dụ `S-CHAR`, `C-LUFFY`, `O-SINGLE`) để các file đặc tả chỉ cần ghi "ghép S-CHAR + C-LUFFY + P-IDLE + O-STRIP(4) + AVOID".
- Luôn **đính kèm ảnh tham chiếu** (mục 6). Prompt không có ảnh tham chiếu cho kết quả lệch phong cách rất nhiều.
- Sửa prompt ở đây khi tìm được câu tốt hơn — mọi đặc tả tự động hưởng lợi.

## 2. Khối phong cách (STYLE)

### S-CHAR — nhân vật / sinh vật
```
Pixel art game sprite in the exact style of the attached reference image: a tiny chibi
character about 24 pixels tall drawn on a 64x64 pixel grid, displayed upscaled 16x so every
pixel is a crisp, perfectly square, equal-sized block aligned to one strict grid. Big head
(about 40% of total height), short body and limbs, simple dark 2-pixel eyes. Flat colors with
2 to 3 shades per material (base, shadow, tiny highlight). No black outline: edges are defined
only by the darker shade of each color. Muted, slightly warm, soft palette, about 12 colors.
```

### S-PROP — chướng ngại vật, item, đồ vật
```
Pixel art game object in the exact style of the attached reference image: drawn on a small
pixel grid, displayed upscaled so every pixel is a crisp, perfectly square, equal-sized block
on one strict grid. Simple readable shape, flat colors with 2 to 3 shades, no black outline
(edges use the darker shade of each color), muted slightly warm palette, at most 8 colors.
```

### S-ENV — lớp nền
```
Pixel art background layer for a side-scrolling 2D game, matching the pixel scale and flat
shading of the attached character sprite: every pixel is a crisp, perfectly square block on
one strict grid, simple blocky shapes, low detail, flat color areas with 2 to 3 shades, no
outlines. The sky (if any) uses 3 to 5 flat horizontal color bands instead of a gradient.
Limited palette of about 16 colors. Calm and readable so that characters in front stand out.
```

### S-VFX — hiệu ứng
```
Pixel art visual effect sprite, crisp square pixels on a strict grid, flat bright colors with
2 to 3 shades, no glow, no blur, no soft transparency, bold simple shapes that read clearly
at very small size.
```

### S-UI — giao diện
```
Pixel art user interface element for a mobile game, crisp square pixels on a strict grid,
flat colors with 2 shades, rounded-corner pixel shapes, warm cream and dark brown color
scheme matching the attached reference, clean and readable, no text unless specified.
```

## 3. Khối nhân vật (SUBJECT — C-*)

Mỗi khối mô tả **ngoại hình cố định** để mọi prompt của nhân vật đó giống nhau.

### C-LUFFY
```
Character: a cheerful young pirate boy. Straw hat with a red band (straw colors #E2C397,
#AC906A, band #90191C), short messy black hair (#222124), small scar under the left eye,
open red short-sleeve vest with two yellow buttons (#90191C, shadow #771516), bare chest,
blue denim knee-length shorts with rolled cuffs (#5571A3, #3F5C8B), bare legs, simple
sandals, light skin (#EADAC0, shadow #D0BF9C).
```

### C-ZORO
```
Character: a stern young swordsman. Short spiky light-green hair (#9DD479, #77A05A, #64854C),
narrow serious eyes, white short-sleeve shirt (#E7E8FC, shadow #CFD0E2), green sash around the
waist, black trousers (#212123, #39383D) and black boots, three katanas at the left hip with
grey blades (#B7B5B8, #646466), tanned skin (#EBD9C1, shadow #D7C0A0).
```

### C-NAMI
```
Character: a young navigator girl. Long bright orange hair (#FFA001, #ED8301, #D37500),
white and blue horizontally striped tank top (#E7E8FC, #01529F), orange short skirt, brown
sandals, a thin segmented staff held in one hand, light skin (#F0E0C8, shadow #DECAAD).
```

### C-SANJI
```
Character: a slim young cook. Blond hair covering one eye (#D4B830 with darker shade), curly
eyebrow, cigarette with a small grey smoke trail, black suit jacket and trousers (#212123,
#39383D), blue shirt, dark tie, black shoes, light skin.
```

### C-USOPP
```
Character: a lanky young sniper with a long straight nose. Curly black hair under an olive
green bandana hat, brown overalls with a white shirt, a bag strapped across the chest, a
slingshot, olive goggles on the forehead, brown skin.
```

### C-CHOPPER
```
Character: a tiny reindeer doctor, shorter than the others (about 16 pixels tall). Big pink
top hat with a white X cross on the front, small antlers poking through the hat, brown fur,
blue nose, purple shorts, a blue backpack.
```

### C-ROBIN
```
Character: a tall calm archaeologist woman. Long straight black hair, dark purple cowboy
hat, purple outfit, sunglasses pushed up on the hat, light skin.
```

### C-FRANKY
```
Character: a big cyborg shipwright. Spiky light-blue pompadour hair, sunglasses, huge
forearms with blue star tattoos, open red Hawaiian shirt with yellow-green flower pattern,
dark blue speedo swimsuit, bare legs.
```

## 4. Khối đầu ra (OUTPUT — O-*)

### O-SINGLE — một tư thế
```
Side view, the character faces RIGHT. One single pose, centered horizontally, feet resting on
an invisible ground line near the bottom of the frame. Plain solid flat background of pure
magenta (#FF00FF) filling the entire image, no ground, no drop shadow, no text, no border,
no other objects. Square 1:1 image.
```

### O-STRIP(n) — dải n frame animation
```
A horizontal animation strip of exactly {n} frames in a single row, each frame in an
equal-width cell, evenly spaced, with the same character at the same size, same scale, same
colors and the same ground line in every frame — only the pose changes. The character faces
RIGHT in every frame. Plain solid flat pure magenta (#FF00FF) background everywhere, no grid
lines, no frame numbers, no text. Frames from left to right: {frame list}.
```

### O-EDIT — sửa từ ảnh đã duyệt (cách giữ nhân vật nhất quán tốt nhất)
```
Edit the attached sprite. Keep the character, proportions, pixel size, palette, colors and
position of the feet exactly the same. Change ONLY the pose to: {pose}. Keep the plain pure
magenta (#FF00FF) background.
```

### O-PROP — đồ vật
```
Single object, side view, centered, resting on an invisible ground line near the bottom.
Plain solid flat pure magenta (#FF00FF) background, no shadow, no text, no other objects.
Square 1:1 image.
```

### O-LAYER(w,h) — lớp nền tileable
```
Wide panoramic image, aspect ratio {w}:{h}. Horizontally seamless and tileable: the left edge
must continue perfectly into the right edge. Everything that is not part of this layer (for
example the sky above far mountains) must be plain solid pure magenta (#FF00FF) so it can be
removed. No characters, no text.
```

## 5. Khối tránh (AVOID)

```
Do not add black outlines, gradients, anti-aliasing, blur, glow, dithering, noise textures,
3D rendering, vector-smooth curves, motion blur, text, numbers, watermarks, frames or a
background scene. Do not change the proportions or the colors of the character. Do not make
pixels of different sizes.
```

## 6. Ảnh tham chiếu đính kèm

| Mục đích | Đính kèm | Vì sao |
|---|---|---|
| Phong cách chung | `assets/charactors/l_z_n_s_u_c.png` (6 nhân vật cùng một ảnh) | Model thấy rõ mật độ pixel, tỉ lệ, màu |
| Nhận diện nhân vật | `assets/charactors/<id>_normal.png` | Giữ đúng trang phục, màu |
| Frame tiếp theo của animation | Frame đã duyệt gần nhất, **xuất phóng to 16× nearest** từ Aseprite | Giữ nhất quán giữa các frame |
| Nền | 1 sprite nhân vật đã duyệt + (tuỳ chọn) ảnh bố cục phác tay | Ép mật độ pixel của nền bằng nhân vật |


## 7. Mẹo theo model

- **Gemini (Nano Banana / Gemini image)**: rất mạnh ở **chỉnh sửa ảnh có sẵn** (O-EDIT) — cách tốt nhất để ra frame mới mà nhân vật vẫn y hệt. Quy trình nên là: gen 1 frame `idle` thật chuẩn → mọi tư thế khác đều làm bằng O-EDIT từ frame đó.
- **ChatGPT (GPT image)**: tốt ở dải nhiều frame (O-STRIP) và hiểu bố cục; hay tự thêm viền/nền → nhắc lại AVOID.
- Cả hai hay vẽ **pixel giả** (ô không đều, viền mờ) → luôn chạy qua `tools/pixelize.py`.
- Gen 3–4 biến thể, chọn cái tốt nhất, đừng cố sửa prompt cho tới khi hoàn hảo — phần còn lại sửa tay trong Aseprite nhanh hơn.
- Model hay **sai số frame** và **lệch chân** giữa các frame trong O-STRIP → coi O-STRIP là bản nháp tư thế; căn chân, sửa tay là bình thường.

## 8. Ghi lại prompt đã dùng

Mỗi ảnh gen giữ lại phải có file đi kèm cùng tên `.prompt.md` trong `art-source/raw/...`:
```
model: gemini-... / gpt-image-...
date: YYYY-MM-DD
references: [đường dẫn các ảnh đính kèm]
prompt: |
  (prompt đầy đủ đã dùng)
notes: chọn biến thể 2/4, lệch chân phải 1px, sửa trong Aseprite
```
Vì: khi cần gen lại hoặc gen nhân vật mới cùng kiểu, có công thức chính xác.
