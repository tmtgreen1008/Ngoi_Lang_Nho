# Đợt 6: Địa hình, cây cối và ngoại cảnh

Ô nền theo mùa, đất canh tác, nước, ruộng, đường, cây lớn, hàng rào, công trình, xe cộ, đồ đường làng.

> Bảng tổng và nguyên tắc chung: [ASSET_CATALOG.md](ASSET_CATALOG.md). Mỗi prompt tự chứa khối STYLE và bảng 17 màu: copy nguyên khối.
> Làm trong cùng một cuộc trò chuyện ChatGPT đã gửi *ảnh neo*, đính kèm ảnh tham chiếu ghi ở mỗi mục nếu có.

| # | Asset | File | Ưu tiên |
|---|---|---|---|
| 77 | Ô nền mùa Hè | `tiles/terrain_summer.png` | ★★ |
| 78 | Ô nền mùa Thu | `tiles/terrain_autumn.png` | ★★ |
| 79 | Ô nền mùa Đông | `tiles/terrain_winter.png` | ★★ |
| 80 | Đất canh tác | `tiles/farmland.png` | ★★★ |
| 81 | Chướng ngại trên ruộng | `props/field_obstacles.png` | ★★ |
| 82 | Bờ nước (16 ô ghép) | `tiles/water_shore.png` | ★★★ |
| 83 | Nước chuyển động | `tiles/water_anim.png` | ★ |
| 84 | Ruộng lúa | `tiles/paddy.png` | ★★ |
| 85 | Đường và lát nền | `tiles/paths.png` | ★★ |
| 86 | Nền và tường trong nhà | `tiles/interior.png` | ★★★ |
| 87 | Cây lớn mùa Xuân | `props/trees_spring.png` | ★★★ |
| 88 | Cây lớn đổi theo mùa | `props/trees_seasons.png` | ★★ |
| 89 | Bụi cây, hoa, cỏ | `props/flora_small.png` | ★★ |
| 90 | Hàng rào và cổng | `props/fences.png` | ★★★ |
| 91 | Công trình nông nghiệp lớn | `props/farm_structures.png` | ★★ |
| 92 | Trạm chế biến | `props/crafting_stations.png` | ★★ |
| 93 | Xe cộ và thuyền | `props/vehicles.png` | ★ |
| 94 | Cầu và bến | `props/bridge_dock.png` | ★★ |
| 95 | Công trình công cộng | `props/public_buildings.png` | ★ |
| 96 | Mặt tiền các tiệm khác | `props/shop_facades.png` | ★ |
| 97 | Đồ đường làng | `props/street_props.png` | ★★ |

---

## 77. Ô nền mùa Hè (`tiles/terrain_summer.png`)

Ô nền Hè thay bộ mùa Xuân đang dùng (terrain_tiles.png). Sàn gỗ/quán net giữ nguyên nên không vẽ lại.

*Cỡ ô cuối dự kiến: 48x48 px. Đính kèm tham chiếu: tiles/terrain_tiles.png.*

```
Create a pixel-art seamless terrain tileset arranged in a clean grid of 4 columns by 2 rows (8 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Every cell is one square tile drawn top-down that fills its whole cell edge to edge. Each tile must tile seamlessly with itself on all four edges unless its description says otherwise. No magenta background anywhere. Cells in reading order (left to right, top row first): (1) lush bright grass; (2) grass with tiny yellow #E8C547 and white #FFF8E7 summer flowers; (3) dry hard-packed dirt path with fine cracks; (4) tilled soil, dry; (5) market ground, dusty, with bright light; (6) pond water, clear with strong #FFF8E7 sparkle pixels; (7) tall lush grass, darker and denser; (8) grass with scattered small pebbles. SUMMER look: lush, saturated, strong sunlight. Grass is bright #6FAE3F with darker #2F5D34 tufts. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Strict top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. No outlines; separate shapes with a darker shade of the same color instead. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 48x48 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 78. Ô nền mùa Thu (`tiles/terrain_autumn.png`)

Ô nền Thu thay bộ mùa Xuân đang dùng (terrain_tiles.png). Sàn gỗ/quán net giữ nguyên nên không vẽ lại.

*Cỡ ô cuối dự kiến: 48x48 px. Đính kèm tham chiếu: tiles/terrain_tiles.png.*

```
Create a pixel-art seamless terrain tileset arranged in a clean grid of 4 columns by 2 rows (8 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Every cell is one square tile drawn top-down that fills its whole cell edge to edge. Each tile must tile seamlessly with itself on all four edges unless its description says otherwise. No magenta background anywhere. Cells in reading order (left to right, top row first): (1) dry olive-yellow grass; (2) grass with fallen orange and red leaves; (3) dirt path with scattered leaves; (4) tilled soil, damp, with a few leaves; (5) market ground with fallen leaves and straw; (6) pond water, slightly darker, with floating leaves; (7) grass with dense leaf litter; (8) bare packed earth with straw. AUTUMN look: warm golden light. Grass is olive-yellow mixed #5B9A3C and #C9A66B, fallen orange #D9803A and red #B5472F leaves are everywhere. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Strict top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. No outlines; separate shapes with a darker shade of the same color instead. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 48x48 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 79. Ô nền mùa Đông (`tiles/terrain_winter.png`)

Ô nền Đông thay bộ mùa Xuân đang dùng (terrain_tiles.png). Sàn gỗ/quán net giữ nguyên nên không vẽ lại.

*Cỡ ô cuối dự kiến: 48x48 px. Đính kèm tham chiếu: tiles/terrain_tiles.png.*

```
Create a pixel-art seamless terrain tileset arranged in a clean grid of 4 columns by 2 rows (8 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Every cell is one square tile drawn top-down that fills its whole cell edge to edge. Each tile must tile seamlessly with itself on all four edges unless its description says otherwise. No magenta background anywhere. Cells in reading order (left to right, top row first): (1) dull cold grass; (2) grass with frost patches; (3) dirt path, cold and damp, darker; (4) tilled soil, damp and dark with a little frost; (5) market ground, damp, dark; (6) pond water, dark and cold with thin pale ice patches; (7) frosty withered grass; (8) bare cold earth with frost. WINTER look in northern Vietnam: cold, grey-green, misty, NOT a snowy landscape. Grass is dull #5B9A3C mixed with #C9A66B, with pale frost patches in #F1E6C8 and #5FA8A8. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Strict top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. No outlines; separate shapes with a darker shade of the same color instead. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 48x48 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 80. Đất canh tác (`tiles/farmland.png`)

Đất cuốc khô/ướt, mới gieo, cỏ dại, cây héo.

*Cỡ ô cuối dự kiến: 48x48 px. Đính kèm tham chiếu: tiles/terrain_tiles.png.*

```
Create a pixel-art seamless terrain tileset arranged in a clean grid of 4 columns by 2 rows (8 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Every cell is one square tile drawn top-down that fills its whole cell edge to edge. Each tile must tile seamlessly with itself on all four edges unless its description says otherwise. No magenta background anywhere. Cells in reading order (left to right, top row first): (1) dry tilled soil with parallel furrows, variant A; (2) dry tilled soil, variant B; (3) wet tilled soil: darker #4E3320 with a few #5FA8A8 water pixels, variant A; (4) wet tilled soil, variant B; (5) freshly sown dry soil with small seed holes in a regular pattern; (6) freshly sown wet soil; (7) soil overgrown with green weeds; (8) soil with dead withered brown stalks. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Strict top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. No outlines; separate shapes with a darker shade of the same color instead. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 48x48 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 81. Chướng ngại trên ruộng (`props/field_obstacles.png`)

Vật cản cần dọn khi khai hoang.

*Cỡ ô cuối dự kiến: 48x48 px. Đính kèm tham chiếu: props/decor_sheet.png.*

```
Create a pixel-art prop sprite sheet arranged in a clean grid of 4 columns by 2 rows (8 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE prop, centered horizontally and resting on a common baseline near the bottom of its cell, drawn large to fill most of the cell. Do not paint ground, grass or cast shadows under props (the game adds shadows). Cells in reading order (left to right, top row first): (1) small grey stone; (2) large boulder with moss; (3) tree stump; (4) fallen log; (5) clump of weeds; (6) fallen branch; (7) tall wild grass clump; (8) mole mound of fresh earth. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 48x48 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 82. Bờ nước (16 ô ghép) (`tiles/water_shore.png`)

Ghép bờ ao/sông (autotile đơn giản). Các ô viền phải khớp cạnh với ô cỏ và ô nước.

*Cỡ ô cuối dự kiến: 48x48 px. Đính kèm tham chiếu: tiles/terrain_tiles.png.*

```
Create a pixel-art seamless terrain tileset arranged in a clean grid of 4 columns by 4 rows (16 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Every cell is one square tile drawn top-down that fills its whole cell edge to edge. Each tile must tile seamlessly with itself on all four edges unless its description says otherwise. No magenta background anywhere. Cells in reading order (left to right, top row first): (1) deep pond water; (2) shallow pond water, lighter; (3) water with a lily pad and a small pink lotus; (4) rippled water; (5) shore edge where grass is on the TOP half and water on the BOTTOM half, with a soft muddy bank; (6) shore edge with grass on the BOTTOM half and water on the TOP half; (7) shore edge with grass on the LEFT half and water on the RIGHT half; (8) shore edge with grass on the RIGHT half and water on the LEFT half; (9) OUTER corner: water fills only the bottom-right quarter, grass elsewhere; (10) OUTER corner: water fills only the bottom-left quarter; (11) OUTER corner: water fills only the top-right quarter; (12) OUTER corner: water fills only the top-left quarter; (13) INNER corner: grass fills only the top-left quarter, water elsewhere; (14) INNER corner: grass fills only the top-right quarter; (15) INNER corner: grass fills only the bottom-left quarter; (16) INNER corner: grass fills only the bottom-right quarter. The grass part must match the plain grass tile and the water part must match the pond water tile exactly so edges join cleanly. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Strict top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. No outlines; separate shapes with a darker shade of the same color instead. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 48x48 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 83. Nước chuyển động (`tiles/water_anim.png`)

4 khung cho ao (hàng trên) và sông chảy (hàng dưới). Các khung chỉ khác nhau chút xíu.

*Cỡ ô cuối dự kiến: 48x48 px. Đính kèm tham chiếu: tiles/terrain_tiles.png.*

```
Create a pixel-art seamless terrain tileset arranged in a clean grid of 4 columns by 2 rows (8 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Every cell is one square tile drawn top-down that fills its whole cell edge to edge. Each tile must tile seamlessly with itself on all four edges unless its description says otherwise. No magenta background anywhere. Cells in reading order (left to right, top row first): (1) pond water, animation frame 1; (2) pond water, frame 2 (ripples shifted); (3) pond water, frame 3; (4) pond water, frame 4; (5) river water flowing from left to right, frame 1; (6) river water, frame 2 (current lines shifted right); (7) river water, frame 3; (8) river water, frame 4. Frames of the same row must be nearly identical except that the ripple or current pixels shift slightly, and the last frame must loop back to the first. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Strict top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. No outlines; separate shapes with a darker shade of the same color instead. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 48x48 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 84. Ruộng lúa (`tiles/paddy.png`)

Ruộng lúa nước, bờ ruộng, mương.

*Cỡ ô cuối dự kiến: 48x48 px. Đính kèm tham chiếu: tiles/terrain_tiles.png.*

```
Create a pixel-art seamless terrain tileset arranged in a clean grid of 4 columns by 2 rows (8 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Every cell is one square tile drawn top-down that fills its whole cell edge to edge. Each tile must tile seamlessly with itself on all four edges unless its description says otherwise. No magenta background anywhere. Cells in reading order (left to right, top row first): (1) flooded empty paddy field, muddy water with reflections; (2) paddy with young bright green rice rows; (3) paddy with golden ripe rice rows; (4) earth dike (bo ruong) running horizontally with grass on top; (5) earth dike running vertically; (6) dike corner piece; (7) irrigation ditch running horizontally; (8) irrigation ditch running vertically. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Strict top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. No outlines; separate shapes with a darker shade of the same color instead. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 48x48 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 85. Đường và lát nền (`tiles/paths.png`)

Các loại mặt đường và sân.

*Cỡ ô cuối dự kiến: 48x48 px. Đính kèm tham chiếu: tiles/terrain_tiles.png.*

```
Create a pixel-art seamless terrain tileset arranged in a clean grid of 4 columns by 2 rows (8 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Every cell is one square tile drawn top-down that fills its whole cell edge to edge. Each tile must tile seamlessly with itself on all four edges unless its description says otherwise. No magenta background anywhere. Cells in reading order (left to right, top row first): (1) flat stone slab path; (2) grey concrete village road with a faint crack; (3) red brick-paved yard; (4) loose gravel; (5) wooden bridge planks running horizontally; (6) dirt road with cart wheel ruts; (7) round cobblestones; (8) stepping stones set in grass. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Strict top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. No outlines; separate shapes with a darker shade of the same color instead. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 48x48 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 86. Nền và tường trong nhà (`tiles/interior.png`)

Sàn và tường cho trong nhà (tường nhìn thẳng mặt trước).

*Cỡ ô cuối dự kiến: 48x48 px. Đính kèm tham chiếu: tiles/terrain_tiles.png.*

```
Create a pixel-art seamless terrain tileset arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Every cell is one square tile drawn top-down that fills its whole cell edge to edge. Each tile must tile seamlessly with itself on all four edges unless its description says otherwise. No magenta background anywhere. Cells in reading order (left to right, top row first): (1) warm wooden floor, light; (2) dark wooden floor; (3) red clay tile floor; (4) old blue-and-cream mosaic floor tiles typical of Vietnamese houses; (5) woven bamboo mat floor; (6) woven rug pattern in red #B5472F and cream; (7) wall front face: vertical wood panels; (8) wall front face: whitewashed plaster in #F1E6C8 with faint stains; (9) lower wall (wainscot) band in wood; (10) baseboard strip, repeats horizontally; (11) wall top edge with a soft dark shadow line; (12) door threshold strip in worn wood. Wall tiles show the front face of a wall seen straight on; floor tiles are top-down. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Strict top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. No outlines; separate shapes with a darker shade of the same color instead. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 48x48 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 87. Cây lớn mùa Xuân (`props/trees_spring.png`)

Cây lớn dựng làm cảnh/viền map.

*Cỡ ô cuối dự kiến: 128x160 px. Đính kèm tham chiếu: props/decor_sheet.png.*

```
Create a pixel-art prop sprite sheet arranged in a clean grid of 4 columns by 2 rows (8 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE prop, centered horizontally and resting on a common baseline near the bottom of its cell, drawn large to fill most of the cell. Do not paint ground, grass or cast shadows under props (the game adds shadows). Cells in reading order (left to right, top row first): (1) huge banyan tree (da) with hanging aerial roots and a wide canopy; (2) clump of bamboo; (3) banana plants cluster; (4) mango tree; (5) longan tree; (6) coconut palm; (7) weeping willow; (8) flame tree (phuong) with a few red #B5472F flowers. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 128x160 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 88. Cây lớn đổi theo mùa (`props/trees_seasons.png`)

Biến thể theo mùa cho 4 cây chính. Cùng dáng với bản Xuân.

*Cỡ ô cuối dự kiến: 128x160 px. Đính kèm tham chiếu: props/trees_spring.png.*

```
Create a pixel-art prop sprite sheet arranged in a clean grid of 3 columns by 4 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE prop, centered horizontally and resting on a common baseline near the bottom of its cell, drawn large to fill most of the cell. Do not paint ground, grass or cast shadows under props (the game adds shadows). Cells in reading order (left to right, top row first): (1) banyan, SUMMER: deep green; (2) banyan, AUTUMN: slightly yellowing; (3) banyan, WINTER: thinner, dull green; (4) weeping willow, SUMMER: lush; (5) weeping willow, AUTUMN: golden strands; (6) weeping willow, WINTER: bare drooping branches; (7) flame tree, SUMMER: covered in red #B5472F flowers; (8) flame tree, AUTUMN: orange leaves; (9) flame tree, WINTER: bare branches; (10) mango tree, SUMMER: heavy with green mangoes; (11) mango tree, AUTUMN: dull green; (12) mango tree, WINTER: dull green and sparse. Each row is one tree and the three columns are SUMMER, AUTUMN and WINTER. Keep the exact trunk and silhouette of the spring version; only leaves and flowers change. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 128x160 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 89. Bụi cây, hoa, cỏ (`props/flora_small.png`)

Cây nhỏ rải làm đẹp.

*Cỡ ô cuối dự kiến: 48x48 px. Đính kèm tham chiếu: props/decor_sheet.png.*

```
Create a pixel-art prop sprite sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE prop, centered horizontally and resting on a common baseline near the bottom of its cell, drawn large to fill most of the cell. Do not paint ground, grass or cast shadows under props (the game adds shadows). Cells in reading order (left to right, top row first): (1) round green bush; (2) white chrysanthemum patch; (3) red hibiscus bush; (4) lotus leaves floating pad; (5) tall pampas grass; (6) red-capped mushrooms; (7) fern; (8) wild herb patch; (9) purple wildflower patch; (10) small bamboo shoot clump; (11) tall reed grass; (12) yellow dandelion patch. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 48x48 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 90. Hàng rào và cổng (`props/fences.png`)

Hàng rào tre, gỗ, tường gạch, cổng.

*Cỡ ô cuối dự kiến: 64x64 px. Đính kèm tham chiếu: props/decor_sheet.png.*

```
Create a pixel-art prop sprite sheet arranged in a clean grid of 4 columns by 2 rows (8 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE prop, centered horizontally and resting on a common baseline near the bottom of its cell, drawn large to fill most of the cell. Do not paint ground, grass or cast shadows under props (the game adds shadows). Cells in reading order (left to right, top row first): (1) bamboo fence section, horizontal; (2) bamboo fence corner; (3) bamboo gate, closed; (4) bamboo gate, open; (5) wooden picket fence section; (6) low brick wall section; (7) brick gate pillar; (8) small wooden village gate arch. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 64x64 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 91. Công trình nông nghiệp lớn (`props/farm_structures.png`)

Kho thóc, lán nông cụ, chòi canh ruộng, nhà lưới.

*Cỡ ô cuối dự kiến: 192x160 px. Đính kèm tham chiếu: props/house.png.*

```
Create a pixel-art prop sprite sheet arranged in a clean grid of 2 columns by 2 rows (4 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE prop, centered horizontally and resting on a common baseline near the bottom of its cell, drawn large to fill most of the cell. Do not paint ground, grass or cast shadows under props (the game adds shadows). Cells in reading order (left to right, top row first): (1) rice granary barn with a thatched roof on stilts; (2) tool shed with a tin roof and tools leaning on the wall; (3) field watch hut on stilts with a thatch roof; (4) net greenhouse tunnel with a bamboo frame. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 192x160 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 92. Trạm chế biến (`props/crafting_stations.png`)

Cối xay, bếp, lò, bàn chế biến, chum, ép mía, bàn ươm, giàn phơi.

*Cỡ ô cuối dự kiến: 96x96 px. Đính kèm tham chiếu: props/decor_sheet.png.*

```
Create a pixel-art prop sprite sheet arranged in a clean grid of 4 columns by 2 rows (8 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE prop, centered horizontally and resting on a common baseline near the bottom of its cell, drawn large to fill most of the cell. Do not paint ground, grass or cast shadows under props (the game adds shadows). Cells in reading order (left to right, top row first): (1) stone rice-mill grinder; (2) wood-fired clay stove with a pot; (3) brick kiln; (4) wooden chopping and preparation table; (5) large clay fermentation jar with a lid; (6) sugarcane press; (7) seedling nursery table with trays; (8) bamboo drying rack with items hung. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 96x96 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 93. Xe cộ và thuyền (`props/vehicles.png`)

Phương tiện làng quê.

*Cỡ ô cuối dự kiến: 128x96 px. Đính kèm tham chiếu: props/decor_sheet.png.*

```
Create a pixel-art prop sprite sheet arranged in a clean grid of 4 columns by 2 rows (8 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE prop, centered horizontally and resting on a common baseline near the bottom of its cell, drawn large to fill most of the cell. Do not paint ground, grass or cast shadows under props (the game adds shadows). Cells in reading order (left to right, top row first): (1) old bicycle; (2) old motorbike; (3) ox cart with wooden wheels; (4) wheelbarrow; (5) small wooden rowboat; (6) round woven basket boat (thung chai); (7) cargo tricycle (xe tho); (8) handcart. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 128x96 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 94. Cầu và bến (`props/bridge_dock.png`)

Cầu gỗ, cầu khỉ, bến thuyền, biển chỗ câu cá.

*Cỡ ô cuối dự kiến: 128x96 px. Đính kèm tham chiếu: props/decor_sheet.png.*

```
Create a pixel-art prop sprite sheet arranged in a clean grid of 3 columns by 2 rows (6 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE prop, centered horizontally and resting on a common baseline near the bottom of its cell, drawn large to fill most of the cell. Do not paint ground, grass or cast shadows under props (the game adds shadows). Cells in reading order (left to right, top row first): (1) wooden plank bridge, horizontal; (2) wooden plank bridge, vertical; (3) bamboo monkey bridge; (4) small boat dock jetty; (5) mooring post with a rope; (6) blank wooden sign on a post for the fishing spot. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 128x96 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 95. Công trình công cộng (`props/public_buildings.png`)

Đình, miếu, trường, trạm y tế, nhà văn hóa, bưu điện. Mọi bảng hiệu để trống.

*Cỡ ô cuối dự kiến: 256x192 px. Đính kèm tham chiếu: props/house.png.*

```
Create a pixel-art prop sprite sheet arranged in a clean grid of 3 columns by 2 rows (6 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE prop, centered horizontally and resting on a common baseline near the bottom of its cell, drawn large to fill most of the cell. Do not paint ground, grass or cast shadows under props (the game adds shadows). Cells in reading order (left to right, top row first): (1) village communal house (dinh lang) with a curved tiled roof; (2) small village shrine (mieu) with incense urn; (3) small primary school building with a flagpole; (4) small health station building with a plain red cross sign; (5) culture house with a loudspeaker on the roof; (6) post office or commune office building. All signboards must be left blank with no writing. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 256x192 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 96. Mặt tiền các tiệm khác (`props/shop_facades.png`)

Mặt tiền tiệm phở, may, thuốc, bánh mì, cắt tóc, sửa xe. Biển trống.

*Cỡ ô cuối dự kiến: 192x160 px. Đính kèm tham chiếu: props/grocery_facade.png.*

```
Create a pixel-art prop sprite sheet arranged in a clean grid of 3 columns by 2 rows (6 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE prop, centered horizontally and resting on a common baseline near the bottom of its cell, drawn large to fill most of the cell. Do not paint ground, grass or cast shadows under props (the game adds shadows). Cells in reading order (left to right, top row first): (1) pho noodle shop with steam and small stools; (2) tailor shop with fabric rolls and a mannequin; (3) traditional medicine shop with herb drawers visible; (4) bread bakery with a baguette display; (5) barber shop with a chair visible; (6) bicycle and motorbike repair shop with tires hung. All signboards must be left blank with no writing. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 192x160 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 97. Đồ đường làng (`props/street_props.png`)

Ghế đá, bàn thấp, bàn cờ, võng, dù, đèn, cột điện, loa phường, bảng thông báo...

*Cỡ ô cuối dự kiến: 64x64 px. Đính kèm tham chiếu: props/decor_sheet.png.*

```
Create a pixel-art prop sprite sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE prop, centered horizontally and resting on a common baseline near the bottom of its cell, drawn large to fill most of the cell. Do not paint ground, grass or cast shadows under props (the game adds shadows). Cells in reading order (left to right, top row first): (1) stone bench; (2) low plastic table with two stools; (3) outdoor Chinese chess board on a stool; (4) hammock slung between two posts; (5) large market umbrella; (6) trash bin; (7) street lamp; (8) utility pole with wires; (9) village loudspeaker on a pole; (10) blank notice board with a roof; (11) mailbox; (12) public water tap with a basin. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 64x64 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```
