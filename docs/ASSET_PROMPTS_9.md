# Đợt 9: Hiệu ứng và mini-game

Hiệu ứng hạt/thời tiết/hoạt ảnh môi trường và bộ ảnh cho các mini-game.

> Bảng tổng và nguyên tắc chung: [ASSET_CATALOG.md](ASSET_CATALOG.md). Mỗi prompt tự chứa khối STYLE và bảng 17 màu: copy nguyên khối.
> Làm trong cùng một cuộc trò chuyện ChatGPT đã gửi *ảnh neo*, đính kèm ảnh tham chiếu ghi ở mỗi mục nếu có.

| # | Asset | File | Ưu tiên |
|---|---|---|---|
| 134 | Hiệu ứng hành động | `fx/fx_actions.png` | ★★ |
| 135 | Thời tiết và hạt bay | `fx/fx_weather.png` | ★★ |
| 136 | Hoạt ảnh môi trường | `fx/fx_environment.png` | ★ |
| 137 | Mini-game Quán Net: bộ ảnh | `minigames/aim_kit.png` | ★★ |
| 138 | Mini-game Bida: bàn nhìn từ trên | `minigames/billiards_table_top.png` | ★★ |
| 139 | Mini-game Bida: phụ kiện | `minigames/billiards_kit.png` | ★★ |
| 140 | Mini-game Câu cá: bộ ảnh | `minigames/fishing_kit.png` | ★ |
| 141 | Ô ăn quan: bàn cờ | `minigames/o_an_quan_board.png` | ★ |
| 142 | Ô ăn quan: quân cờ | `minigames/o_an_quan_pieces.png` | ★ |

---

## 134. Hiệu ứng hành động (`fx/fx_actions.png`)

Bụi cuốc, nước bắn, thu hoạch, xu lấp lánh, tim bay, khói. Mỗi hàng một hiệu ứng, 4 khung.

*Cỡ ô cuối dự kiến: 32x32 px. Đính kèm tham chiếu: icons/item_icons.png.*

```
Create a pixel-art visual effect sprite sheet arranged in a clean grid of 4 columns by 6 rows (24 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE effect frame, centered, bright and clearly readable. Draw only the effect itself: no objects, no characters, no ground. Cells in reading order (left to right, top row first): (1) dust puff frame 1 (small); (2) dust puff frame 2; (3) dust puff frame 3; (4) dust puff frame 4 (faded); (5) water splash frame 1; (6) water splash frame 2; (7) water splash frame 3; (8) water splash frame 4; (9) harvest pop frame 1: small star burst; (10) harvest pop frame 2; (11) harvest pop frame 3; (12) harvest pop frame 4; (13) coin sparkle frame 1; (14) coin sparkle frame 2; (15) coin sparkle frame 3; (16) coin sparkle frame 4; (17) floating heart frame 1; (18) floating heart frame 2; (19) floating heart frame 3; (20) floating heart frame 4; (21) smoke puff frame 1; (22) smoke puff frame 2; (23) smoke puff frame 3; (24) smoke puff frame 4. Each ROW is one effect and the four columns are its animation frames from start to end. Use only the palette colors, mostly #FFF8E7, #E8C547, #5FA8A8 and #B5472F. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. No outlines; separate shapes with a darker shade of the same color instead. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 32x32 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 135. Thời tiết và hạt bay (`fx/fx_weather.png`)

Mưa, gợn nước, bông tuyết/sương, lá và cánh hoa rơi.

*Cỡ ô cuối dự kiến: 32x32 px. Đính kèm tham chiếu: icons/item_icons.png.*

```
Create a pixel-art visual effect sprite sheet arranged in a clean grid of 4 columns by 4 rows (16 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE effect frame, centered, bright and clearly readable. Draw only the effect itself: no objects, no characters, no ground. Cells in reading order (left to right, top row first): (1) rain streak, small; (2) rain streak, medium; (3) rain streak, long; (4) rain splash on the ground; (5) puddle ripple frame 1; (6) puddle ripple frame 2; (7) puddle ripple frame 3; (8) puddle ripple frame 4; (9) snowflake, small; (10) snowflake, medium; (11) snowflake, large; (12) mist puff, soft cloud; (13) falling green leaf; (14) falling golden leaf; (15) falling red leaf; (16) falling pink peach petal. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. No outlines; separate shapes with a darker shade of the same color instead. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 32x32 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 136. Hoạt ảnh môi trường (`fx/fx_environment.png`)

Khói ống khói, lửa bếp, cờ bay, đèn lồng chập chờn, nước lấp lánh. Mỗi hàng 4 khung lặp vòng.

*Cỡ ô cuối dự kiến: 48x48 px. Đính kèm tham chiếu: icons/item_icons.png.*

```
Create a pixel-art visual effect sprite sheet arranged in a clean grid of 4 columns by 5 rows (20 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE effect frame, centered, bright and clearly readable. Draw only the effect itself: no objects, no characters, no ground. Cells in reading order (left to right, top row first): (1) chimney smoke frame 1; (2) chimney smoke frame 2; (3) chimney smoke frame 3; (4) chimney smoke frame 4; (5) cooking fire frame 1; (6) cooking fire frame 2; (7) cooking fire frame 3; (8) cooking fire frame 4; (9) red flag waving frame 1; (10) red flag waving frame 2; (11) red flag waving frame 3; (12) red flag waving frame 4; (13) lantern flicker frame 1; (14) lantern flicker frame 2; (15) lantern flicker frame 3; (16) lantern flicker frame 4; (17) water sparkle frame 1; (18) water sparkle frame 2; (19) water sparkle frame 3; (20) water sparkle frame 4. Each ROW is one looping animation of 4 frames. Keep the object in exactly the same position in each frame. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. No outlines; separate shapes with a darker shade of the same color instead. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 48x48 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 137. Mini-game Quán Net: bộ ảnh (`minigames/aim_kit.png`)

Tâm ngắm, bia thường/vàng/phạt, hiệu ứng trúng/trượt, khung màn hình.

*Cỡ ô cuối dự kiến: 64x64 px. Đính kèm tham chiếu: minigames/aim_target.png.*

```
Create a pixel-art UI element sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE flat UI element, centered with padding, crisp and symmetrical, no perspective, no text, no letters, no numbers. Cells in reading order (left to right, top row first): (1) crosshair, thin, in #B5472F; (2) normal target (red and cream concentric rings); (3) golden target (bonus), #E8C547 rings; (4) penalty target (blue #3E5C8A with a small skull-free cross); (5) hit spark; (6) miss puff; (7) countdown plate: a round wooden plate, plain; (8) game-over badge: a wooden plaque, plain; (9) monitor frame: a beige computer monitor bezel with the screen filled magenta; (10) desktop wallpaper tile: a repeating subtle diamond pattern in #3E5C8A and #2B2B33; (11) headset; (12) joystick. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 64x64 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 138. Mini-game Bida: bàn nhìn từ trên (`minigames/billiards_table_top.png`)

Mặt bàn bida để chơi mini-game (bi và cơ vẽ riêng).

*Cỡ ô cuối dự kiến: 320x192 px. Đính kèm tham chiếu: props/billiards_table.png.*

```
Create a single pixel-art prop sprite sheet: a pool table seen straight from above: green #5B9A3C felt with a darker #2F5D34 border, brown #7A5230 wooden cushions with #E8C547 diamond markers, six dark pockets (four corners and two on the long sides), no balls and no cue. Each cell contains exactly ONE prop, centered horizontally and resting on a common baseline near the bottom of its cell, drawn large to fill most of the cell. Do not paint ground, grass or cast shadows under props (the game adds shadows). Seen strictly top-down, not in 3/4 view. Fill the table to the image edges, with the area outside the wooden frame filled with magenta. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 320x192 pixels: design the art on that pixel grid with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 139. Mini-game Bida: phụ kiện (`minigames/billiards_kit.png`)

Cơ, phấn, đường ngắm, thanh lực, bi sọc.

*Cỡ ô cuối dự kiến: 64x64 px. Đính kèm tham chiếu: minigames/billiard_balls.png.*

```
Create a pixel-art UI element sheet arranged in a clean grid of 4 columns by 2 rows (8 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE flat UI element, centered with padding, crisp and symmetrical, no perspective, no text, no letters, no numbers. Cells in reading order (left to right, top row first): (1) cue stick, horizontal, with a blue chalked tip; (2) cube of blue chalk; (3) aiming guide dots, a short dotted line; (4) power meter frame, a vertical wooden bar with a plain empty track; (5) ball shadow, a soft dark ellipse made of a few pixels; (6) striped ball in red #B5472F; (7) striped ball in blue #3E5C8A; (8) pocket highlight ring. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 64x64 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 140. Mini-game Câu cá: bộ ảnh (`minigames/fishing_kit.png`)

Cho mini-game câu cá ở ao: cá bóng, phao, lưỡi câu, thanh bắt cá.

*Cỡ ô cuối dự kiến: 64x64 px. Đính kèm tham chiếu: icons/fish.png (sau khi có).*

```
Create a pixel-art UI element sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE flat UI element, centered with padding, crisp and symmetrical, no perspective, no text, no letters, no numbers. Cells in reading order (left to right, top row first): (1) small fish silhouette in #2B2B33; (2) medium fish silhouette; (3) large fish silhouette; (4) bobber floating idle; (5) bobber pulled down (bite) frame 1; (6) bobber bite frame 2; (7) fishing hook; (8) vertical CATCH BAR frame: a tall wooden bar with an empty track; (9) green #6FAE3F catch zone block, same width as the track; (10) fish marker, a tiny bright fish icon; (11) water splash ring; (12) treasure sack. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 64x64 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 141. Ô ăn quan: bàn cờ (`minigames/o_an_quan_board.png`)

Bàn trò chơi dân gian (tuỳ chọn).

*Cỡ ô cuối dự kiến: 512x256 px. Đính kèm tham chiếu: props/decor_sheet.png.*

```
Create a single pixel-art pixel-art illustration: a wooden traditional Vietnamese o an quan board seen straight from above: a rectangle with ten square cells in two rows of five in the middle, and two large semicircular cells at the left and right ends; carved wooden lines, warm #A67C52 wood with #7A5230 grooves, empty cells, on a plain #F1E6C8 tablecloth background. A complete wide 16:9 landscape scene with rich but readable pixel detail, using stepped color bands instead of smooth gradients, no close-up faces. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Wide 16:9 landscape composition. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. No outlines; separate shapes with a darker shade of the same color instead. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 512x256 pixels: design the art on that pixel grid with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 142. Ô ăn quan: quân cờ (`minigames/o_an_quan_pieces.png`)

Sỏi nhỏ và quan lớn.

*Cỡ ô cuối dự kiến: 64x64 px. Đính kèm tham chiếu: minigames/o_an_quan_board.png (sau khi có).*

```
Create a pixel-art item icon sheet arranged in a clean grid of 4 columns by 1 rows (4 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE icon: a single object, centered, filling about 70 percent of the cell, with a clear silhouette that stays recognizable at small size. Cells in reading order (left to right, top row first): (1) small white pebble (dan); (2) small pebble in #3E5C8A; (3) big ornate quan piece in #E8C547; (4) small pile of five pebbles. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view with a very slight top-down tilt, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 64x64 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```
