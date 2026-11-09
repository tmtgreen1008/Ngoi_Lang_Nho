# Đợt 5: Vật phẩm và cây trồng

Icon mọi vật phẩm trong kho đồ/cửa hàng và hình các giai đoạn lớn của cây trồng.

> Bảng tổng và nguyên tắc chung: [ASSET_CATALOG.md](ASSET_CATALOG.md). Mỗi prompt tự chứa khối STYLE và bảng 17 màu: copy nguyên khối.
> Làm trong cùng một cuộc trò chuyện ChatGPT đã gửi *ảnh neo*, đính kèm ảnh tham chiếu ghi ở mỗi mục nếu có.

| # | Asset | File | Ưu tiên |
|---|---|---|---|
| 62 | Công cụ (cơ bản) | `icons/tools_basic.png` | ★★★ |
| 63 | Công cụ (nâng cấp) | `icons/tools_upgrade.png` | ★ |
| 64 | Hạt giống | `icons/seeds.png` | ★★★ |
| 65 | Nông sản A | `icons/crops_a.png` | ★★★ |
| 66 | Nông sản B (trái cây, hoa, đặc sản) | `icons/crops_b.png` | ★★ |
| 67 | Sản phẩm vật nuôi | `icons/animal_products.png` | ★★ |
| 68 | Cá và thủy sản | `icons/fish.png` | ★★ |
| 69 | Món ăn A | `icons/food_a.png` | ★★ |
| 70 | Món ăn B và đồ uống | `icons/food_b.png` | ★ |
| 71 | Nguyên liệu | `icons/materials.png` | ★★ |
| 72 | Hàng tạp hóa | `icons/goods.png` | ★★ |
| 73 | Đồ sưu tầm và quà | `icons/collectibles.png` | ★ |
| 74 | Cây trồng lớn lên A | `crops/growth_a.png` | ★★★ |
| 75 | Cây trồng lớn lên B | `crops/growth_b.png` | ★★ |
| 76 | Cây ăn quả lớn lên | `crops/fruit_trees.png` | ★ |

---

## 62. Công cụ (cơ bản) (`icons/tools_basic.png`)

Công cụ bản gỗ/sắt thường.

*Cỡ ô cuối dự kiến: 64x64 px. Đính kèm tham chiếu: icons/item_icons.png.*

```
Create a pixel-art item icon sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE icon: a single object, centered, filling about 70 percent of the cell, with a clear silhouette that stays recognizable at small size. Cells in reading order (left to right, top row first): (1) hoe with a wooden handle and iron blade; (2) watering can with a spout; (3) sickle; (4) axe; (5) pickaxe; (6) shovel; (7) bamboo fishing rod with a line; (8) hammer; (9) long-handled scythe; (10) woven bamboo harvest basket; (11) small fishing net; (12) pruning shears. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view with a very slight top-down tilt, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 64x64 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 63. Công cụ (nâng cấp) (`icons/tools_upgrade.png`)

Hai bậc nâng cấp cho 6 công cụ (cùng dáng với bản cơ bản, đổi vật liệu).

*Cỡ ô cuối dự kiến: 64x64 px. Đính kèm tham chiếu: icons/tools_basic.png.*

```
Create a pixel-art item icon sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE icon: a single object, centered, filling about 70 percent of the cell, with a clear silhouette that stays recognizable at small size. Cells in reading order (left to right, top row first): (1) hoe, iron tier with a grey-blue blade; (2) hoe, golden tier with a #E8C547 blade; (3) watering can, iron tier; (4) watering can, golden tier; (5) axe, iron tier; (6) axe, golden tier; (7) pickaxe, iron tier; (8) pickaxe, golden tier; (9) fishing rod, iron-tipped tier; (10) fishing rod, golden tier; (11) sickle, iron tier; (12) sickle, golden tier. Keep the shapes identical to the basic tools; only the material and color change. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view with a very slight top-down tilt, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 64x64 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 64. Hạt giống (`icons/seeds.png`)

Gói hạt giống cho 12 cây trồng. Mỗi gói một màu giấy khác nhau, không chữ.

*Cỡ ô cuối dự kiến: 64x64 px. Đính kèm tham chiếu: icons/item_icons.png.*

```
Create a pixel-art item icon sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE icon: a single object, centered, filling about 70 percent of the cell, with a clear silhouette that stays recognizable at small size. Cells in reading order (left to right, top row first): (1) paper seed packet with a rice plant drawing; (2) seed packet with a tomato drawing; (3) seed packet with a cabbage drawing; (4) seed packet with a cucumber drawing; (5) seed packet with a water spinach drawing; (6) seed packet with a corn cob drawing; (7) seed packet with a carrot drawing; (8) seed packet with a sweet potato drawing; (9) seed packet with a chili pepper drawing; (10) seed packet with a pumpkin drawing; (11) seed packet with a watermelon drawing; (12) seed packet with a bean drawing. Each packet has a different pale paper tint and a small drawing of the plant, with no text. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view with a very slight top-down tilt, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 64x64 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 65. Nông sản A (`icons/crops_a.png`)

Nông sản thu hoạch của 12 cây trồng.

*Cỡ ô cuối dự kiến: 64x64 px. Đính kèm tham chiếu: icons/item_icons.png.*

```
Create a pixel-art item icon sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE icon: a single object, centered, filling about 70 percent of the cell, with a clear silhouette that stays recognizable at small size. Cells in reading order (left to right, top row first): (1) bundle of golden rice stalks; (2) ripe red tomato; (3) cabbage head; (4) cucumber; (5) bunch of water spinach; (6) corn cob with husk; (7) orange carrot with green top; (8) sweet potato; (9) red chili peppers; (10) orange pumpkin; (11) slice and whole watermelon; (12) green bean pods. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view with a very slight top-down tilt, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 64x64 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 66. Nông sản B (trái cây, hoa, đặc sản) (`icons/crops_b.png`)

Trái cây, hoa và đặc sản.

*Cỡ ô cuối dự kiến: 64x64 px. Đính kèm tham chiếu: icons/item_icons.png.*

```
Create a pixel-art item icon sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE icon: a single object, centered, filling about 70 percent of the cell, with a clear silhouette that stays recognizable at small size. Cells in reading order (left to right, top row first): (1) orange (cam); (2) guava; (3) bunch of bananas; (4) mango; (5) jackfruit; (6) longan cluster; (7) pomelo; (8) pink lotus flower; (9) yellow chrysanthemum; (10) sunflower; (11) bamboo shoot; (12) straw mushroom. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view with a very slight top-down tilt, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 64x64 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 67. Sản phẩm vật nuôi (`icons/animal_products.png`)

Trứng, sữa, thịt, mật ong, phân.

*Cỡ ô cuối dự kiến: 64x64 px. Đính kèm tham chiếu: icons/item_icons.png.*

```
Create a pixel-art item icon sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE icon: a single object, centered, filling about 70 percent of the cell, with a clear silhouette that stays recognizable at small size. Cells in reading order (left to right, top row first): (1) chicken egg; (2) duck egg; (3) quail eggs in a small bunch; (4) bottle of fresh milk; (5) raw pork cut; (6) chicken drumstick; (7) beef cut; (8) jar of honey; (9) bag of manure fertilizer; (10) feather; (11) jar of fish sauce; (12) jar of pickled vegetables. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view with a very slight top-down tilt, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 64x64 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 68. Cá và thủy sản (`icons/fish.png`)

Cá, tôm, cua, ốc ở ao/sông.

*Cỡ ô cuối dự kiến: 64x64 px. Đính kèm tham chiếu: icons/item_icons.png.*

```
Create a pixel-art item icon sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE icon: a single object, centered, filling about 70 percent of the cell, with a clear silhouette that stays recognizable at small size. Cells in reading order (left to right, top row first): (1) climbing perch; (2) carp; (3) catfish; (4) snakehead fish; (5) crucian carp; (6) tilapia; (7) freshwater prawn; (8) field crab; (9) apple snail; (10) eel; (11) clam; (12) small loach. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view with a very slight top-down tilt, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 64x64 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 69. Món ăn A (`icons/food_a.png`)

Món ăn nấu được.

*Cỡ ô cuối dự kiến: 64x64 px. Đính kèm tham chiếu: icons/item_icons.png.*

```
Create a pixel-art item icon sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE icon: a single object, centered, filling about 70 percent of the cell, with a clear silhouette that stays recognizable at small size. Cells in reading order (left to right, top row first): (1) bowl of white rice; (2) bowl of pho; (3) banh chung (square sticky rice cake in green leaves); (4) banh mi baguette; (5) sticky rice in a banana leaf; (6) sour fish soup in a pot; (7) braised fish in a clay pot; (8) fried egg on a plate; (9) stir-fried water spinach on a plate; (10) mung bean sweet soup in a glass; (11) rolled steamed rice pancakes; (12) fried spring rolls. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view with a very slight top-down tilt, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 64x64 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 70. Món ăn B và đồ uống (`icons/food_b.png`)

Món phụ và đồ uống.

*Cỡ ô cuối dự kiến: 64x64 px. Đính kèm tham chiếu: icons/item_icons.png.*

```
Create a pixel-art item icon sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE icon: a single object, centered, filling about 70 percent of the cell, with a clear silhouette that stays recognizable at small size. Cells in reading order (left to right, top row first): (1) rice porridge; (2) banh xeo crispy pancake; (3) fresh summer rolls; (4) banh tet cylindrical rice cake; (5) sugarcane juice in a glass; (6) green tea cup with a small teapot; (7) iced milk coffee in a tall glass; (8) soy milk in a glass; (9) peanut candy; (10) rice paper cracker; (11) bowl of cooked instant noodles; (12) mooncake. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view with a very slight top-down tilt, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 64x64 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 71. Nguyên liệu (`icons/materials.png`)

Gỗ, tre, đá, quặng, rơm, dây, vải...

*Cỡ ô cuối dự kiến: 64x64 px. Đính kèm tham chiếu: icons/item_icons.png.*

```
Create a pixel-art item icon sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE icon: a single object, centered, filling about 70 percent of the cell, with a clear silhouette that stays recognizable at small size. Cells in reading order (left to right, top row first): (1) wood log; (2) bundle of branches (firewood); (3) bamboo poles; (4) grey stone; (5) iron ore; (6) lump of coal; (7) straw bundle; (8) rope coil; (9) roll of cloth; (10) clay lump; (11) small sand pile; (12) clay bricks. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view with a very slight top-down tilt, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 64x64 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 72. Hàng tạp hóa (`icons/goods.png`)

Hàng bán ở tiệm tạp hóa.

*Cỡ ô cuối dự kiến: 64x64 px. Đính kèm tham chiếu: icons/item_icons.png.*

```
Create a pixel-art item icon sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE icon: a single object, centered, filling about 70 percent of the cell, with a clear silhouette that stays recognizable at small size. Cells in reading order (left to right, top row first): (1) sack of rice; (2) sack of flour; (3) bag of sugar; (4) bag of salt; (5) bottle of fish sauce; (6) bottle of cooking oil; (7) sack of fertilizer; (8) box of matches; (9) candle; (10) oil lamp; (11) pair of rubber sandals; (12) conical palm-leaf hat. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view with a very slight top-down tilt, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 64x64 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 73. Đồ sưu tầm và quà (`icons/collectibles.png`)

Quà tặng, đồ cổ, đồ sưu tầm.

*Cỡ ô cuối dự kiến: 64x64 px. Đính kèm tham chiếu: icons/item_icons.png.*

```
Create a pixel-art item icon sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE icon: a single object, centered, filling about 70 percent of the cell, with a clear silhouette that stays recognizable at small size. Cells in reading order (left to right, top row first): (1) ancient round coin with a square hole; (2) ceramic vase; (3) miniature bronze drum; (4) Dong Ho folk painting in a frame (no text); (5) colorful to he dough figurine; (6) paper kite; (7) star-shaped lantern; (8) traditional two-stringed fiddle; (9) paper folding fan; (10) jade stone; (11) amber piece; (12) carved wooden figurine. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view with a very slight top-down tilt, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 64x64 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 74. Cây trồng lớn lên A (`crops/growth_a.png`)

3 giai đoạn x 6 cây (mỗi hàng một cây). Vẽ đè lên ô đất nên nền trong suốt.

*Cỡ ô cuối dự kiến: 48x48 px. Đính kèm tham chiếu: crops/rice_stages.png.*

```
Create a pixel-art prop sprite sheet arranged in a clean grid of 3 columns by 6 rows (18 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE prop, centered horizontally and resting on a common baseline near the bottom of its cell, drawn large to fill most of the cell. Do not paint ground, grass or cast shadows under props (the game adds shadows). Cells in reading order (left to right, top row first): (1) tomato plant, stage 1: tiny seedling; (2) tomato, stage 2: growing with a stake; (3) tomato, stage 3: ripe with red tomatoes; (4) cabbage, stage 1: tiny sprout; (5) cabbage, stage 2: leafy young; (6) cabbage, stage 3: full round head; (7) cucumber, stage 1: sprout; (8) cucumber, stage 2: vine on a small trellis; (9) cucumber, stage 3: hanging cucumbers; (10) water spinach, stage 1: sprout; (11) water spinach, stage 2: leafy; (12) water spinach, stage 3: tall lush bunch; (13) corn, stage 1: sprout; (14) corn, stage 2: tall stalk; (15) corn, stage 3: ripe cobs; (16) carrot, stage 1: sprout; (17) carrot, stage 2: leafy top; (18) carrot, stage 3: orange top poking out of the soil. Each row is one crop and the three columns are its growth stages. Plants sit at the bottom-center of the cell. Do not draw soil (the soil is a separate tile). Stage 3 must look clearly harvestable. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 48x48 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 75. Cây trồng lớn lên B (`crops/growth_b.png`)

6 cây tiếp theo.

*Cỡ ô cuối dự kiến: 48x48 px. Đính kèm tham chiếu: crops/growth_a.png.*

```
Create a pixel-art prop sprite sheet arranged in a clean grid of 3 columns by 6 rows (18 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE prop, centered horizontally and resting on a common baseline near the bottom of its cell, drawn large to fill most of the cell. Do not paint ground, grass or cast shadows under props (the game adds shadows). Cells in reading order (left to right, top row first): (1) sweet potato, stage 1: sprout; (2) sweet potato, stage 2: vines; (3) sweet potato, stage 3: lush vines with a tuber showing; (4) chili, stage 1: sprout; (5) chili, stage 2: bush with flowers; (6) chili, stage 3: red chilies; (7) pumpkin, stage 1: sprout; (8) pumpkin, stage 2: broad leaves; (9) pumpkin, stage 3: orange pumpkin; (10) watermelon, stage 1: sprout; (11) watermelon, stage 2: vine; (12) watermelon, stage 3: striped watermelon; (13) green bean, stage 1: sprout; (14) green bean, stage 2: climbing a bamboo pole; (15) green bean, stage 3: hanging pods; (16) spring onion, stage 1: sprout; (17) spring onion, stage 2: clump; (18) spring onion, stage 3: tall bunch. Each row is one crop and the three columns are its growth stages. Plants sit at the bottom-center of the cell. Do not draw soil. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 48x48 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 76. Cây ăn quả lớn lên (`crops/fruit_trees.png`)

Cây lâu năm: cây non, cây lớn, cây có quả.

*Cỡ ô cuối dự kiến: 64x96 px. Đính kèm tham chiếu: crops/growth_a.png.*

```
Create a pixel-art prop sprite sheet arranged in a clean grid of 3 columns by 4 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE prop, centered horizontally and resting on a common baseline near the bottom of its cell, drawn large to fill most of the cell. Do not paint ground, grass or cast shadows under props (the game adds shadows). Cells in reading order (left to right, top row first): (1) orange tree, stage 1: young sapling; (2) orange tree, stage 2: full green tree; (3) orange tree, stage 3: tree full of orange fruit; (4) guava tree, stage 1: sapling; (5) guava tree, stage 2: full tree; (6) guava tree, stage 3: tree with green-yellow fruit; (7) banana plant, stage 1: sapling; (8) banana plant, stage 2: tall plant; (9) banana plant, stage 3: plant with a hanging bunch of bananas; (10) longan tree, stage 1: sapling; (11) longan tree, stage 2: full tree; (12) longan tree, stage 3: tree with hanging fruit clusters. Each row is one fruit tree and the three columns are its stages. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 64x96 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```
