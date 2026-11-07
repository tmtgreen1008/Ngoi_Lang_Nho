# Asset đợt 3: chuồng trại, ao, phiên chợ, xóm làng, khu giải trí

Đợt này nhằm **mở rộng bốn khu** đang còn trống (xem [ASSET_PROMPTS_2.md](ASSET_PROMPTS_2.md) cho đợt trước):

| Khu | Hiện trạng | Sau đợt này |
|---|---|---|
| Khu nhà | Nhà, vườn lưới, vài cây | Có chuồng gà/lợn, ao, giếng, giàn mướp, sân phơi, vật nuôi |
| Chợ Quê | Một sạp, nền gỗ phẳng | Phiên chợ nhiều sạp (rau, thịt, cá, trái cây, trứng, đồ gia dụng), cổng chợ, mái chợ, người đi chợ |
| Tạp hóa | Một gian tạp hóa | Xóm nhỏ: tiệm nhìn từ ngoài, nhà dân, cây đa, miếu, đường làng |
| Giải trí | Nền caro, bàn máy và bàn bida trơ trọi | Quán net, quán bida, quán nước, sân chơi, nền lát |

**Cách dùng y hệt đợt 1 và 2:** dùng lại cuộc trò chuyện cũ với ChatGPT (để giữ phong cách), đính kèm một
ảnh đã duyệt làm tham chiếu (vd. `props/decor_sheet.png` cho đồ vật, `tiles/terrain_tiles.png` cho ô nền,
`characters/player_sheet.png` cho nhân vật), rồi dán từng prompt. Tải **ảnh gốc** bằng nút tải xuống, đặt vào
`assets/art/source/` rồi báo tôi. Tôi sẽ đo cỡ pixel, xử lý bằng `tools/slice_sheet.gd` và nối vào game.

> Phần STYLE trong mỗi prompt là khối phong cách và bảng 17 màu chung của dự án, giữ nguyên.
> Chữ trên biển hiệu do game vẽ (tránh AI viết sai dấu tiếng Việt), nên mọi biển phải **để trống**.

## Thứ tự nên làm

Làm theo **từng khu** để dựng được map sớm thay vì chờ đủ hết. Mỗi khu có một nhóm ưu tiên cao (★):
thiếu thì không dựng được bố cục, còn lại là phần làm đẹp.

| Khu | Ưu tiên cao (★) | Làm đẹp |
|---|---|---|
| Chợ | 30 sạp, 33 nền chợ, 34 người dân | 31 đồ chợ, 32 cổng/mái |
| Khu nhà | 26 chuồng trại, 27 ao, 29 vật nuôi | 28 đồ sân vườn |
| Xóm tạp hóa | 35 nhà dân, 36 mặt tiền tiệm, 38 nền xóm | 37 đồ xóm |
| Giải trí | 39 mặt tiền quán, 41 nền giải trí | 40 đồ giải trí |

## Bảng tổng hợp

| # | Asset | File lưu (trong `assets/art/`) |
|---|---|---|
| 26 | Chuồng trại (3 món) | `props/farm_buildings.png` |
| 27 | Ao làng (2 cỡ) | `props/pond.png` |
| 28 | Đồ sân vườn (6 món) | `props/yard_props.png` |
| 29 | Vật nuôi (7 con) | `props/animals.png` |
| 30 | Sạp chợ (6 kiểu, không chữ) | `props/market_stalls.png` |
| 31 | Đồ chợ lặt vặt (8 món) | `props/market_clutter.png` |
| 32 | Cổng chợ, mái chợ (3 món) | `props/market_gate.png` |
| 33 | Ô nền chợ (8 ô) | `tiles/market_tiles.png` |
| 34 | Người dân (6 nhân vật) | `characters/villagers.png` |
| 35 | Nhà dân ở xóm (3 kiểu) | `props/village_houses.png` |
| 36 | Mặt tiền Tiệm Tạp Hóa | `props/grocery_facade.png` |
| 37 | Đồ xóm làng (8 món) | `props/village_props.png` |
| 38 | Ô nền xóm làng (8 ô) | `tiles/village_tiles.png` |
| 39 | Mặt tiền Quán Net và Quán Bida | `props/entertainment_facades.png` |
| 40 | Đồ giải trí ngoài trời (8 món) | `props/leisure_props.png` |
| 41 | Ô nền khu giải trí (8 ô) | `tiles/leisure_tiles.png` |

Cỡ cuối cùng sẽ chốt sau khi đo mật độ pixel thực tế của ảnh AI (như đã làm ở các đợt trước); cỡ "px" ghi
trong prompt chỉ là tỷ lệ tương đối so với Player cao 48 px.

---

## 26. Chuồng trại (3 món) (`props/farm_buildings.png`)

Thứ tự: chuồng gà, chuồng lợn, máng ăn kèm rổ thóc. Mỗi chuồng chừa một khoảng cửa rõ để game đặt con vật.

```
Create a pixel-art sheet of 3 farm animal structures for a Vietnamese village yard, arranged in a single row of 3 cells, equal cells with no gaps and no grid lines drawn, each item centered and resting on a common baseline near the bottom of its cell, slight 3/4 top-down view. (1) A small chicken coop: a little wooden hut with a sloped roof of #C9A66B thatch, planks in #A67C52 and #7A5230, a tiny arched doorway, a short ramp, and a low bamboo-fenced run in front, about 96 px wide; (2) a pigsty: a low brick-and-wood shed with a #B5472F clay-tile roof, brick walls in #E8B88A and #B5472F, an open front, and a small fenced mud yard in #7A5230 in front with a puddle of #5FA8A8 water, about 128 px wide; (3) a long wooden feeding trough in #A67C52 with some #E8C547 grain in it, next to a woven bamboo basket full of #E8C547 rice grain, small, about 64 px wide. Solid flat pure magenta #FF00FF background, no shadow on the background. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every prop. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no watermark, no signature. Match the pixel density of the attached reference image.
```

## 27. Ao làng (2 cỡ) (`props/pond.png`)

Ao to và ao nhỏ, **không có chữ, không có cá** (game thêm cá và gợn sóng sau). Mặt nước phẳng để game phủ hiệu ứng.

```
Create a pixel-art sheet of 2 village ponds arranged in one row of 2 cells of different sizes, each seen from a slight 3/4 top-down view. (1) A large irregular oval pond about 256 px wide: calm water in #5FA8A8 and #3E5C8A with a few lighter ripple pixels, a natural muddy bank in #7A5230 and #A67C52 around it with grass tufts #5B9A3C at the edge, a few round green #6FAE3F lily pads with two pink-white #FFF8E7 lotus flowers, tall reeds in #2F5D34 on one side, and a small wooden plank landing in #A67C52 sticking out into the water with two stone steps; (2) a small round pond about 128 px wide with the same style but only reeds and one lily pad, no landing. Both ponds have a soft irregular natural edge, not a perfect circle. Leave plain flat water in the middle of each pond without any fish. Solid flat pure magenta #FF00FF background, no shadow on the background. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every prop. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no watermark, no signature. Match the pixel density of the attached reference image.
```

## 28. Đồ sân vườn (6 món) (`props/yard_props.png`)

Thứ tự: giếng nước, giàn mướp, bể nước xây, cối xay đá, nong phơi thóc, bàn ghế gốc cây.

```
Create a pixel-art prop sheet of 6 Vietnamese countryside yard items arranged in a grid of 3 columns by 2 rows, equal cells with no gaps and no grid lines drawn, each item centered and resting on a common baseline near the bottom of its cell, slight 3/4 top-down view. Items, left to right, top row then bottom row: (1) a traditional round stone well with a small tiled #B5472F roof on two wooden posts and a rope and wooden bucket; (2) a bamboo trellis arch covered in green #6FAE3F gourd vines with a few yellow #E8C547 flowers and two hanging green gourds; (3) a small square brick water tank in #E8B88A and #B5472F with a rim of #5FA8A8 water visible at the top and a coconut-shell dipper beside it; (4) a stone hand mill with a wooden handle, two round gray-brown stones #A67C52 and #7A5230; (5) a large round woven bamboo drying tray (nong) lying on the ground full of #E8C547 spread rice grain with a wooden rake; (6) a tree-stump table in #A67C52 with two small stump stools and a #F1E6C8 teapot and two cups on it. Solid flat pure magenta #FF00FF background, no shadow on the background. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every prop. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no watermark, no signature. Match the pixel density of the attached reference image.
```

## 29. Vật nuôi (7 con) (`props/animals.png`)

Mỗi con **một tư thế đứng nhìn nghiêng**, game tự làm di chuyển. Cỡ nhỏ, ngang tầm Player (Player cao khoảng 48 px, gà chỉ cao khoảng 16 px).

```
Create a pixel-art sheet of 7 cute farm animals arranged in a grid of 4 columns by 2 rows, equal cells with no gaps and no grid lines drawn, each item centered and resting on a common baseline near the bottom of its cell, each shown standing in a side view facing right, very small and simple. Animals, left to right, top row then bottom row: (1) a brown #A67C52 hen with a red #B5472F comb; (2) a rooster with #D9803A and #B5472F feathers and a tall tail; (3) a tiny fluffy yellow #E8C547 chick; (4) a pink #E8B88A pig with a curly tail, plump body; (5) a white #FFF8E7 duck with an #D9803A beak; (6) a small black-and-white village dog with #2B2B33 and #FFF8E7 patches; (7) a water buffalo in dark gray #4E3320 and #2B2B33 with curved horns, larger than the others. Relative sizes: chick smallest, then hen, rooster, duck, dog, pig, and the buffalo clearly the largest. Solid flat pure magenta #FF00FF background, no shadow on the background. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every prop. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no watermark, no signature. Match the pixel density of the attached reference image.
```

## 30. Sạp chợ (6 kiểu, không chữ) (`props/market_stalls.png`)

Thay cho sạp chợ duy nhất hiện nay. Mỗi sạp một ngành hàng, **biển treo để trống** (chữ do game vẽ). Mỗi sạp đặt vừa một người bán đứng phía sau.

```
Create a pixel-art sheet of 6 different Vietnamese open-air market stalls arranged in a grid of 3 columns by 2 rows, equal cells with no gaps and no grid lines drawn, each item centered and resting on a common baseline near the bottom of its cell, slight 3/4 top-down view, each stall about 128 px wide, each with a wooden frame, a canvas awning and an empty space behind the counter for a seller to stand. Stalls, left to right, top row then bottom row: (1) a vegetable stall with a #6FAE3F and #B5472F striped awning and bamboo baskets of green vegetables, tomatoes and cabbage on the counter; (2) a meat stall with a #B5472F awning, hanging cuts of meat on hooks and a wooden chopping block; (3) a fish stall with a #3E5C8A awning and shallow blue tubs holding fish on ice; (4) a fruit stall with a #E8C547 and #D9803A awning and pyramids of oranges, bananas and dragon fruit; (5) an egg and poultry stall with a #C9A66B thatch awning, trays of eggs and a bamboo cage with two chickens; (6) a household goods stall with a #FFF8E7 and #5FA8A8 awning, pots, bowls, brooms and plastic basins. Each stall has a small plain blank hanging wooden board at the front, completely empty, no writing. Solid flat pure magenta #FF00FF background, no shadow on the background. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every prop. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no watermark, no signature. Match the pixel density of the attached reference image.
```

## 31. Đồ chợ lặt vặt (8 món) (`props/market_clutter.png`)

Thứ tự: gánh hàng, xe đẩy rau, thúng rổ chất hàng, lồng gà, chậu cá, bao tải gạo, ô che nắng lớn, ghế đẩu nhựa. Dùng rải lối đi cho phiên chợ đông đúc.

```
Create a pixel-art prop sheet of 8 Vietnamese market props arranged in a grid of 4 columns by 2 rows, equal cells with no gaps and no grid lines drawn, each item centered and resting on a common baseline near the bottom of its cell, slight 3/4 top-down view. Items, left to right, top row then bottom row: (1) a shoulder-pole vendor carrying two bamboo baskets of vegetables, resting on the ground; (2) a wooden hand cart loaded with green vegetables and a few #D9803A pumpkins; (3) a stack of three woven bamboo baskets with fruit and herbs; (4) a round bamboo chicken cage with two #A67C52 chickens inside; (5) a round blue plastic basin #3E5C8A with silver fish; (6) two burlap rice sacks in #C9A66B with #7A5230 ties, one slightly open showing #FFF8E7 rice; (7) a large round beach-style market umbrella in #B5472F and #FFF8E7 stripes on a wooden pole, seen from a slight angle; (8) two small red-and-blue plastic stools stacked. Solid flat pure magenta #FF00FF background, no shadow on the background. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every prop. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no watermark, no signature. Match the pixel density of the attached reference image.
```

## 32. Cổng chợ, mái chợ (3 món) (`props/market_gate.png`)

Cổng vào chợ (ghép thành cụm), mái che chung phía trên dãy sạp, bảng treo trống. Cần bố cục rộng, lòng cổng **trong suốt** để Player đi qua phía dưới.

```
Create a pixel-art sheet of 3 market architecture pieces arranged in one row of 3 cells of different widths, slight 3/4 top-down view. (1) A traditional Vietnamese village market gate: two thick red-brown #B5472F brick pillars with #E8B88A caps, joined by a curved tiled roof #B5472F with #7A5230 beams, wide open space between the pillars, a blank empty wooden board hanging on top (no writing), about 224 px wide; (2) a long shared market roof of #C9A66B thatch and #A67C52 wooden poles, the type that covers a row of stalls, about 256 px wide, open underneath; (3) a smaller covered shelter with four wooden posts and a #B5472F tile roof for the vendors to rest, about 128 px wide with two plain benches beneath. Solid flat pure magenta #FF00FF background, no shadow on the background. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every prop. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no watermark, no signature. Match the pixel density of the attached reference image.
```

## 33. Ô nền chợ (8 ô) (`tiles/market_tiles.png`)

Nền riêng cho phiên chợ: gạch, đất nện, rơm rác. Mọi ô lặp liền mạch.

```
Create a pixel-art tileset sheet of 8 square seamless terrain tiles arranged in a clean grid of 4 columns by 2 rows, equal square cells with no gaps and no grid lines drawn. Each tile must tile seamlessly with itself on all four edges. Tiles, left to right, top row then bottom row: (1) packed dry earth in #C9A66B and #A67C52 with tiny pebbles; (2) a second variation of packed earth with a few footprints and bare spots; (3) old red brick paving in #B5472F, #E8B88A and #7A5230 laid in a simple running bond; (4) a worn variation of the brick paving with a few missing bricks showing earth; (5) earth scattered with loose #E8C547 straw pieces; (6) wet dark earth in #7A5230 and #4E3320 with a couple of #5FA8A8 water puddle pixels; (7) gray-beige stone slabs in #A67C52, #C9A66B and #F1E6C8 with thin #7A5230 joints; (8) earth with a few dropped green #6FAE3F vegetable leaves and a #D9803A scrap. Top-down view, no outlines on terrain, flat colors only. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no letters, no watermark. Design the art on a 48x48 pixel grid per tile and match the pixel density of the attached reference image.
```

## 34. Người dân (6 nhân vật) (`characters/villagers.png`)

Dân làng đứng chợ, đi chợ, ngồi quán. Mỗi người **một tư thế đứng nhìn thẳng** cỡ 32x48 (Player cao 48 px). Dùng làm người bán ở các sạp và người qua lại.

```
Create a pixel-art character sheet of 6 Vietnamese villagers arranged in a single row of 6 equal cells, equal cells with no gaps and no grid lines drawn, each item centered and resting on a common baseline near the bottom of its cell, each character standing facing the viewer, full body, simple chibi proportions with a head about one third of the body height, same pixel density as the attached reference character. Characters, left to right: (1) a middle-aged woman in a brown ao ba ba blouse and trousers with a #C9A66B conical hat (non la) and a #FFF8E7 scarf; (2) an old man with a thin white beard in a #7A5230 shirt and a #3E5C8A cap; (3) a young woman in a #B5472F ao ba ba with a long black braid and no hat; (4) a plump cheerful man in a white #FFF8E7 sleeveless shirt and shorts, a vendor apron in #3E5C8A; (5) an elderly woman with grey hair in a bun, a #5B9A3C blouse and a walking stick; (6) a child of about 8 years in a #E8C547 shirt and #3E5C8A shorts, bare feet. Solid flat pure magenta #FF00FF background, no shadow on the background. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every prop. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no watermark, no signature. Match the pixel density of the attached reference image.
```

## 35. Nhà dân ở xóm (3 kiểu) (`props/village_houses.png`)

Ba ngôi nhà khác nhau để dựng thành xóm. Cùng cỡ pixel với `props/house.png` hiện có, nhưng mỗi nhà khác dáng mái và màu tường để xóm không đơn điệu.

```
Create a pixel-art sheet of 3 different Vietnamese countryside village houses arranged in one row of 3 cells, each about 192 px wide, equal cells with no gaps and no grid lines drawn, each item centered and resting on a common baseline near the bottom of its cell, slight 3/4 top-down view showing the front and the roof. (1) A single-story house with a #B5472F clay-tile roof, #F1E6C8 plastered walls, two wooden shuttered windows and a wooden door, a small raised porch; (2) a poorer thatched-roof house with a #C9A66B straw roof, mud-brick walls in #E8B88A, a bamboo fence in front and a hanging bunch of corn, a single small window; (3) a two-story narrow tube-style Vietnamese townhouse with a flat roof, walls painted #5FA8A8, a balcony with a little #B5472F plant pot, a corrugated iron roof in #7A5230 on the top deck, and a metal shutter door. Solid flat pure magenta #FF00FF background, no shadow on the background. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every prop. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no watermark, no signature. Match the pixel density of the attached reference image.
```

## 36. Mặt tiền Tiệm Tạp Hóa (`props/grocery_facade.png`)

Ngôi tiệm nhìn từ ngoài (hiện chỉ có quầy bên trong). Biển hiệu **để trống**, chữ do game vẽ. Có khoảng cửa mở rõ để người chơi bước vào.

```
Create a single pixel-art building: the front of a small Vietnamese village grocery store (tiem tap hoa), about 224 px wide, slight 3/4 top-down view. A one-story shop with #B5472F tile roof, #F1E6C8 walls, a wide open shopfront with a #E8C547 and #FFF8E7 striped canvas awning, a wooden counter visible inside, wooden shelves with colorful packages, hanging snack bags and a bunch of bananas under the awning, a plain blank wooden sign board above the awning (completely empty, no writing), a single open doorway on the right side, a bicycle leaning against the wall and two stacked #3E5C8A plastic crates beside the door. Solid flat pure magenta #FF00FF background, no shadow on the background. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every prop. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no watermark, no signature. Match the pixel density of the attached reference image.
```

## 37. Đồ xóm làng (8 món) (`props/village_props.png`)

Thứ tự: cây đa to có bệ ngồi, miếu nhỏ, hòm thư, bàn ghế trà đá, xe máy cũ, cột điện, cổng nhà gạch, đống rơm lớn.

```
Create a pixel-art prop sheet of 8 Vietnamese village items arranged in a grid of 4 columns by 2 rows, equal cells with no gaps and no grid lines drawn, each item centered and resting on a common baseline near the bottom of its cell, slight 3/4 top-down view, items of different sizes. Items, left to right, top row then bottom row: (1) a huge old banyan tree (cay da) with a thick gnarled trunk, hanging aerial roots, a dense dark green #2F5D34 and #5B9A3C crown, and a round stone bench around the base, about 160 px wide; (2) a tiny roadside shrine with a small curved #B5472F roof, an incense bowl and an offering of fruit on a stone base, no text or symbols; (3) a red #B5472F metal village mailbox on a wooden post; (4) a low table with two small plastic stools and a #F1E6C8 thermos and glasses, a roadside iced-tea stand; (5) an old parked motorbike in #3E5C8A and #2B2B33; (6) a wooden electric utility pole with sagging black wires cut off at the edges; (7) a small brick house gate with two pillars in #E8B88A and an iron gate in #2B2B33, about 96 px wide; (8) a large conical straw haystack with a bamboo pole through the middle, about 96 px tall. Solid flat pure magenta #FF00FF background, no shadow on the background. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every prop. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no watermark, no signature. Match the pixel density of the attached reference image.
```

## 38. Ô nền xóm làng (8 ô) (`tiles/village_tiles.png`)

Đường làng bê tông, đường gạch, sân xi măng, sân gạch đỏ, mép đường. Mọi ô lặp liền mạch.

```
Create a pixel-art tileset sheet of 8 square seamless terrain tiles arranged in a clean grid of 4 columns by 2 rows, equal square cells with no gaps and no grid lines drawn. Each tile must tile seamlessly with itself on all four edges and must blend visually with a plain green grass tile in #5B9A3C. Tiles, left to right, top row then bottom row: (1) a village concrete road in light gray #C9A66B and #F1E6C8 with thin cracks and tiny dark specks; (2) a worn variation of the concrete road with a darker patch and a small crack; (3) a concrete road edge tile with a strip of grass on top and concrete below, usable as an edge; (4) red brick yard paving in #B5472F, #E8B88A and #7A5230 laid in a herringbone pattern; (5) a plain smooth cement yard in warm gray #C9A66B and #A67C52 with a few stains; (6) a front-yard tile with rice chaff and straw spread on earth in #C9A66B and #E8C547; (7) a roadside drainage ditch tile with #7A5230 earth and a little dark #3E5C8A water; (8) a dirt path with tire tracks in #A67C52 and #7A5230. Top-down view, no outlines on terrain, flat colors only. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no letters, no watermark. Design the art on a 48x48 pixel grid per tile and match the pixel density of the attached reference image.
```

## 39. Mặt tiền Quán Net và Quán Bida (`props/entertainment_facades.png`)

Hai tòa nhà để khu giải trí có cảnh quán thật, thay cho cái bàn máy tính và bàn bida đặt trơ trọi. Biển hiệu **để trống**.

```
Create a pixel-art sheet of 2 small Vietnamese village entertainment buildings arranged in a row of 2 cells, each about 224 px wide, equal cells with no gaps and no grid lines drawn, each item centered and resting on a common baseline near the bottom of its cell, slight 3/4 top-down view showing the front. (1) An internet cafe (quan net): a one-story building with a flat #3E5C8A painted facade, a corrugated metal roof in #7A5230, a large glass front window with the glow of computer screens in #5FA8A8 inside, a glass door, a plain blank rectangular sign board above the door (no writing), a few parked bicycles outside; (2) a billiards hall (quan bida): a wide one-story building with a #B5472F tile roof, #F1E6C8 walls, a wide open front so a green #5B9A3C pool table is visible inside, hanging lamps with #E8C547 light, a plain blank sign board on top (no writing), and a row of cues leaning on the wall. Solid flat pure magenta #FF00FF background, no shadow on the background. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every prop. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no watermark, no signature. Match the pixel density of the attached reference image.
```

## 40. Đồ giải trí ngoài trời (8 món) (`props/leisure_props.png`)

Thứ tự: quán nước có ô, bàn cờ tướng, lưới cầu lông, bàn bóng bàn, máy game thùng, dây đèn lồng, xích đu, ghế đá.

```
Create a pixel-art prop sheet of 8 outdoor leisure items for a village recreation area arranged in a grid of 4 columns by 2 rows, equal cells with no gaps and no grid lines drawn, each item centered and resting on a common baseline near the bottom of its cell, slight 3/4 top-down view. Items, left to right, top row then bottom row: (1) a roadside drink stall (quan nuoc) with a large #B5472F and #FFF8E7 striped umbrella, a cart with glass jars of drinks and colorful plastic stools; (2) a stone Chinese-chess (co tuong) table with a plain carved grid on top and two stone stools, no text; (3) a small badminton net on two thin poles in #A67C52 and #FFF8E7; (4) a green #5B9A3C ping-pong table with a white center line and a net; (5) a retro arcade cabinet in #3E5C8A with a glowing #5FA8A8 screen and #B5472F buttons, no text; (6) a string of red #B5472F paper lanterns hanging between two bamboo poles, seen as a short strip; (7) a rope-and-plank swing hanging from a wooden frame; (8) a long wooden park bench painted #A67C52 with a shaded tree trunk beside it. Solid flat pure magenta #FF00FF background, no shadow on the background. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every prop. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no watermark, no signature. Match the pixel density of the attached reference image.
```

## 41. Ô nền khu giải trí (8 ô) (`tiles/leisure_tiles.png`)

Thay nền caro xanh hiện tại. Sân xi măng, sân bóng, gạch hoa, cỏ có lối đi lát. Mọi ô lặp liền mạch.

```
Create a pixel-art tileset sheet of 8 square seamless terrain tiles arranged in a clean grid of 4 columns by 2 rows, equal square cells with no gaps and no grid lines drawn. Each tile must tile seamlessly with itself on all four edges. Tiles, left to right, top row then bottom row: (1) a cement plaza in #C9A66B and #F1E6C8 with a faint grid of thin joints; (2) a cement plaza variation with a few stains and cracks; (3) decorative patterned floor tiles with a simple #B5472F and #FFF8E7 repeating geometric motif, like Vietnamese encaustic tiles; (4) a second pattern in #3E5C8A and #FFF8E7; (5) a sports court surface in muted #5FA8A8 with faint #FFF8E7 line pixels and tiny scuffs; (6) lush mown grass in #6FAE3F and #5B9A3C with a subtle mowing stripe; (7) grass with square stone paving slabs in #A67C52 arranged as a short path; (8) a dark asphalt tile in #2B2B33 and #4E3320 with fine speckle. Top-down view, no outlines on terrain, flat colors only. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no letters, no watermark. Design the art on a 48x48 pixel grid per tile and match the pixel density of the attached reference image.
```

---

## Khi có ảnh, tôi sẽ nối thế nào

- **26, 29 (chuồng, vật nuôi):** thành thực thể có trạng thái như `FarmField`: nhớ qua chuyển map, bù ngày khi vắng mặt. Gà đẻ trứng theo ngày (đã có vật phẩm `trung_ga`, `cam_ga`), lợn/vịt cần cho ăn. Con vật đi lại bằng code.
- **27, 28:** ao và giếng làm vật chặn đường; ao có thể thêm câu cá sau. Giàn mướp, nong thóc là trang trí/tương tác nhỏ.
- **30-34 (chợ):** map Chợ dựng lại thành nhiều sạp; mỗi sạp một `VendorData` riêng (rau, thịt, cá, trái cây, trứng, đồ gia dụng) có giờ mở cửa riêng, hàng ngẫu nhiên theo ngày vẫn giữ. Người dân đi lại giữa các sạp.
- **35-38 (xóm):** map Tạp hóa thành xóm ngoài trời; bước vào cửa tiệm thì sang map trong tiệm hiện có. Nhà dân là trang trí (có thể thêm cửa vào sau).
- **39-41 (giải trí):** khuôn viên mới; vào cửa quán net/quán bida thì chơi mini-game như hiện nay.

Số ảnh lớn (16 nhóm), nên cứ gửi từng nhóm khi duyệt xong, không cần đủ hết mới bắt đầu.
