# Asset đợt 2: làm sống động map nhà và trong nhà

Đợt này bổ sung những thứ **map đang thiếu** sau khi đã làm đủ đợt 1 (xem
[ASSET_PROMPTS.md](ASSET_PROMPTS.md)): đồ lặt vặt ngoài sân, biển chỉ đường thật, nội thất trong
nhà, và ô nền phá vỡ sự lặp lại của bãi cỏ.

**Cách dùng y hệt đợt 1:** dùng lại cuộc trò chuyện cũ với ChatGPT (để giữ phong cách), đính kèm một
ảnh đợt 1 đã duyệt làm tham chiếu (vd. sheet cây cối), dán từng prompt dưới đây. Tải **ảnh gốc** bằng
nút tải xuống, đặt vào `assets/art/source/` rồi báo tôi. Tôi sẽ đo cỡ pixel, xử lý bằng
`tools/slice_sheet.gd` và nối vào game.

> Phần "STYLE" trong mỗi prompt là khối phong cách và bảng 17 màu chung của dự án, giữ nguyên.

## Bảng tổng hợp

| # | Asset | Nối vào | Cỡ gợi ý |
|---|---|---|---|
| 21 | Đồ lặt vặt ngoài sân (8 món) | map nhà, chợ, các map ngoài trời | 8 khung 48x48 |
| 22 | Dây phơi quần áo | sân nhà | 1 ảnh, rộng khoảng 120 px |
| 23 | Biển chỉ đường (3 kiểu, **không chữ**) | thay biển vẽ bằng code ở `Signpost` | 3 ảnh |
| 24 | Nội thất trong nhà (6 món) | map trong nhà | 6 ảnh |
| 25 | Ô nền bổ sung (8 ô) | phá lặp bãi cỏ, lối mòn sỏi | lưới 4x2, ô 48x48 |

Chữ trên biển chỉ đường do game vẽ (tránh AI viết sai dấu tiếng Việt), nên biển phải để **ván trống**.

---

## 21. Đồ lặt vặt ngoài sân (`props/clutter_sheet.png`)

Thứ tự (trái sang phải, hàng trên rồi hàng dưới): đá nhỏ, cụm đá, đống củi, thùng hứng nước mưa,
đống rơm, thùng gỗ, cụm cỏ cao, khóm hoa dại.

```
Create a pixel-art prop sheet of 8 small outdoor village props arranged in a clean grid of 4 columns by 2 rows, equal square cells with no gaps and no grid lines drawn, each prop centered and resting on a common baseline near the bottom of its cell. Props, left to right, top row then bottom row: (1) one small gray-brown stone in #A67C52 and #7A5230 with a #C9A66B highlight; (2) a cluster of three stones of different sizes, same colors, with a few tiny grass tufts #5B9A3C at the base; (3) a neat stack of cut firewood logs in #A67C52 and #7A5230 showing round #C9A66B log ends, about five logs wide; (4) a round wooden rain barrel with dark #4E3320 iron bands and a little #5FA8A8 water visible at the top; (5) a conical straw haystack in #C9A66B and #E8C547 with a few loose straws; (6) a closed wooden crate in #A67C52 with darker #7A5230 planks and corner nails; (7) a tall wild grass clump with long thin blades in #6FAE3F, #5B9A3C and #2F5D34; (8) a small clump of wildflowers with white #FFF8E7 and orange #D9803A blossoms on green stems. Slight 3/4 top-down view. Solid flat pure magenta #FF00FF background, no shadow on the background. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every prop. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no watermark, no signature. Match the pixel density of the attached reference image.
```

## 22. Dây phơi quần áo (`props/clothesline.png`)

```
Create a single pixel-art prop: a traditional Vietnamese clothesline between two thin bamboo poles, seen from a slight 3/4 top-down angle, wider than tall (about 2:1). The poles are #A67C52 and #7A5230, a sagging cord in #C9A66B between them, and four pieces of laundry hanging: a blue #3E5C8A ao ba ba shirt, a white #FFF8E7 cloth, a brown #7A5230 pair of trousers and a red #B5472F checkered scarf. Simple and readable. Solid flat pure magenta #FF00FF background, no shadow on the background. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A). Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no letters, no watermark. Match the pixel density of the attached reference image.
```

## 23. Biển chỉ đường, không chữ (`props/signposts.png`)

Ba kiểu theo thứ tự: cột 3 ván chỉ phải; cột 1 ván chỉ phải; cột 1 ván chỉ trái. Ván **để trống** vì chữ do game vẽ.

```
Create a pixel-art sheet of 3 wooden village signposts arranged left to right in a single row of 3 equal cells with no gaps and no grid lines drawn, each signpost centered with its base at the bottom of its cell, slight 3/4 top-down view. (1) A sturdy wooden post with THREE stacked blank wooden planks, each plank pointing to the RIGHT with a pointed arrow end, planks in #A67C52 with #C9A66B top highlights and #4E3320 edges, slightly different lengths; (2) a post with ONE blank plank pointing RIGHT; (3) a post with ONE blank plank pointing LEFT. The planks are completely blank and smooth (no text, no letters, no symbols, no carving) with a flat empty area where text can be added later. The posts are #7A5230 with #A67C52 highlights, set in a little mound of dirt #C9A66B at the base. Solid flat pure magenta #FF00FF background, no shadow on the background. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A). Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no letters, no watermark. Match the pixel density of the attached reference image.
```

## 24. Nội thất trong nhà (`props/interior_sheet.png`)

Thứ tự: bàn gỗ kèm hai ghế đẩu, rương gỗ, bếp củi có nồi, kệ chum vại, chiếu cói trải sàn, tủ thờ nhỏ (không chữ).

```
Create a pixel-art furniture sheet for the inside of a small traditional Vietnamese countryside house, 6 items arranged in a clean grid of 3 columns by 2 rows, equal cells with no gaps and no grid lines drawn, each item centered and resting near the bottom of its cell, slight 3/4 top-down view. Items, left to right, top row then bottom row: (1) a low wooden dining table in #A67C52 and #7A5230 with a bowl and two small chopsticks, plus two small round wooden stools beside it; (2) a closed wooden storage chest with dark #4E3320 iron corners and a little lock; (3) a rustic firewood kitchen stove made of clay in #C9A66B and #A67C52 with a black #2B2B33 cooking pot on top and a little #D9803A fire glow at the opening; (4) a low wooden shelf holding three clay jars in #7A5230 and #A67C52; (5) a rectangular woven straw sleeping mat (chieu coi) lying flat on the floor in #E8C547 and #C9A66B with a thin #B5472F border, seen from above, wider than tall; (6) a small wooden household altar cabinet in #7A5230 and #4E3320 with a little incense bowl and two tiny #B5472F candles on top, no text or symbols. Solid flat pure magenta #FF00FF background, no shadow on the background. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A). Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no letters, no watermark. Match the pixel density of the attached reference image.
```

## 25. Ô nền bổ sung (`tiles/terrain_extra.png`)

Dùng để phá sự lặp lại của bãi cỏ và làm lối mòn sỏi. Mọi ô phải **lặp liền mạch**.

```
Create a pixel-art tileset sheet of 8 square seamless terrain tiles arranged in a clean grid of 4 columns by 2 rows, equal square cells with no gaps and no grid lines drawn. Each tile must tile seamlessly with itself on all four edges and must blend visually with a plain green grass tile in #5B9A3C. Tiles, left to right, top row then bottom row: (1) dry yellowed grass in #C9A66B and #5B9A3C with #E8C547 dry blade pixels; (2) a second variation of dry grass with some bare #A67C52 earth spots; (3) tall dark lush grass in #2F5D34 and #5B9A3C with longer blade shapes; (4) grass with patches of bare brown earth #A67C52 and #7A5230, irregular shapes; (5) grass scattered with tiny pebbles in #A67C52, #C9A66B and #F1E6C8; (6) a gravel garden path tile in #C9A66B and #F1E6C8 with many small pebbles and #7A5230 specks; (7) flat stepping-stone slabs in #A67C52 set into grass, simple rounded rectangles; (8) wet dark mud in #4E3320 and #7A5230 with a few tiny #5FA8A8 puddle pixels. Top-down view, no outlines on terrain, flat colors only. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no letters, no watermark. Design the art on a 48x48 pixel grid per tile and match the pixel density of the attached reference image.
```

---

## Khi có ảnh, tôi sẽ nối thế nào

- **21, 22:** rải trong `maps/home`, chợ... bằng hàm đặt đồ vật có sẵn (kèm bóng đổ); đá và củi để ngoài sân, dây phơi cạnh nhà.
- **23:** thay phần vẽ bằng code của `Signpost` bằng ảnh thật, vẫn vẽ chữ bằng font của game lên ván.
- **24:** bố trí lại map trong nhà: bàn ăn, bếp, rương, kệ, chiếu, tủ thờ, có thể thêm bếp để nấu ăn sau này.
- **25:** thêm ô vào bảng ô nền và để `MapBase` dùng cỏ úa/cỏ rậm/đất lởm chởm thật thay cho đốm vẽ bằng code; lối mòn sỏi thay đoạn đường vào vườn.
