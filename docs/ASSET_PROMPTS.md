# Danh sách asset và prompt tạo ảnh (ChatGPT)

> Đợt 2 (đồ lặt vặt ngoài sân, biển chỉ đường, nội thất trong nhà, ô nền bổ sung): xem [ASSET_PROMPTS_2.md](ASSET_PROMPTS_2.md).

Tài liệu này liệt kê **20 nhóm ảnh** cần cho Hương Quê, mỗi nhóm có prompt hoàn chỉnh để dán thẳng vào ChatGPT.
Mọi prompt dùng chung một khối **STYLE** và một **bảng 17 màu** để các ảnh đồng nhất về bối cảnh và màu sắc.

> Prompt viết bằng tiếng Anh vì mô hình tạo ảnh hiểu tốt hơn. Phần giải thích bằng tiếng Việt.

---

## 0. Quy trình làm việc (đọc trước)

1. **Mở một cuộc trò chuyện mới** và dùng nó cho TOÀN BỘ asset, để ChatGPT "nhớ" phong cách.
2. Làm theo thứ tự ưu tiên ở mục 1. Bắt đầu bằng ảnh số 1 (nền đất). Khi bạn **duyệt** ảnh đó, hãy **đính kèm nó** vào các prompt sau và thêm một câu:
   *"Match the exact style, palette, outline and pixel density of the attached reference image."*
3. Mỗi prompt đã chứa khối STYLE đầy đủ, nên dán nguyên văn là được, không cần sửa.
4. Nếu nền không phẳng màu hồng tím (#FF00FF) hoặc có bóng đổ ra nền, gõ: *"Regenerate with a perfectly flat pure magenta #FF00FF background, no shadow on the background, no gradient."*
5. **Hậu kỳ (bắt buộc)**, vì AI không vẽ được pixel chuẩn tuyệt đối:
   - Cắt ảnh theo lưới, **thu nhỏ bằng nearest-neighbor** (không dùng bicubic/bilinear) về đúng kích thước cuối trong bảng.
   - Xoá nền hồng tím #FF00FF thành trong suốt.
   - **Đưa về bảng màu chuẩn** `assets/art/palette.hex` (Aseprite/LibreSprite: *Palette > Load Palette*, rồi *Color Mode > Indexed*; hoặc GIMP: *Image > Mode > Indexed > Use custom palette*). Bước này làm các ảnh khác lượt nhau vẫn cùng màu.
   - Lưu PNG vào đúng đường dẫn trong bảng.
   - **Đã có công cụ làm các bước trên**: `tools/slice_sheet.gd`. Ví dụ với sheet nền đất (cắt vùng ảnh, chia lưới 4x2, thu nhỏ mỗi ô về 48x48, quy về bảng màu):
     `godot --headless --path . -s tools/slice_sheet.gd -- in=anh_tai_ve.png out=assets/art/tiles/terrain_tiles.png cols=4 rows=2 cell=48,48 palette=assets/art/palette.hex`
     Với sheet có nền hồng tím, thêm `key=magenta` để xoá nền. Xem phần đầu `tools/slice_sheet.gd` để biết hết tham số.
   - **Tải ảnh gốc từ ChatGPT** (nút tải xuống), đừng chụp màn hình: chụp màn hình bị nén và lẫn giao diện.
6. Gửi lại cho tôi các file đã xử lý; tôi sẽ nối vào game (thay các khối màu hiện tại) và viết script cắt sheet nếu cần.

**Kích thước ô: dùng 48x48, không phải 32x32.** Thử với sheet nền đất đầu tiên cho thấy AI vẽ khoảng 48 "pixel" mỗi ô dù prompt ghi 32; thu về 32 làm mất gần hết chi tiết (nước, hoa, vân gỗ), còn 48 giữ nguyên. Bảng kích thước bên dưới chỉ là gợi ý ban đầu: sau khi có ảnh của từng nhóm, ta xem mật độ pixel thực tế rồi chốt cỡ cuối, các sprite (người, vật) sẽ theo tỷ lệ với ô 48.

**Giới hạn cần biết:** AI hay vẽ lệch ô lưới, sai số ô, hoặc sai chữ có dấu tiếng Việt. Vì vậy: ảnh nào có chữ (logo) được yêu cầu **không chứa chữ**, chữ sẽ thêm bằng font trong game; sheet nhiều ô có thể phải tạo lại hoặc cắt tay.

---

## 1. Bảng tổng hợp và thứ tự ưu tiên

| # | Asset | File lưu (trong `assets/art/`) | Kích thước cuối | Giai đoạn |
|---|---|---|---|---|
| 1 | Nền đất (8 ô) | `tiles/terrain_tiles.png` | 192x96 (lưới 4x2, ô 48x48) | 1 |
| 2 | Cây lúa 3 giai đoạn | `crops/rice_stages.png` | 96x32 (3 ô 32x32) | 1 |
| 3 | Player (4 hướng x 3 khung) | `characters/player_sheet.png` | 96x192 (lưới 3x4, ô 32x48) | 1 |
| 4 | Bà Tư, chủ tạp hóa | `characters/npc_ba_tu.png` | 64x48 (2 khung 32x48) | 1 |
| 5 | Chú Năm, bán rau ở chợ | `characters/npc_chu_nam.png` | 64x48 (2 khung 32x48) | 1 |
| 6 | Icon 10 vật phẩm | `icons/item_icons.png` | 320x128 (lưới 5x2, ô 64x64) | 1 |
| 7 | Ngôi nhà | `props/house.png` | 192x128 | 2 |
| 8 | Giường có màn | `props/bed.png` | 64x64 | 2 |
| 9 | Quầy tạp hóa | `props/grocery_counter.png` | 128x64 | 2 |
| 10 | Sạp chợ | `props/market_stall.png` | 128x96 | 2 |
| 11 | Máy tính quán net | `props/net_pc_station.png` | 96x64 | 2 |
| 12 | Bàn bida | `props/billiards_table.png` | 128x80 | 2 |
| 13 | Cây cối, hàng rào (5 món) | `props/decor_sheet.png` | 320x64 (5 ô 64x64) | 2 |
| 14 | Khung bảng giấy (9-slice) | `ui/panel_paper.png` | 96x96 | 3 |
| 15 | Nút bấm 3 trạng thái | `ui/buttons.png` | 160x144 (3 hàng 160x48) | 3 |
| 16 | Icon HUD (7 icon) | `ui/hud_icons.png` | 128x64 (lưới 4x2, ô 32x32) | 3 |
| 17 | Logo (không chữ) | `ui/logo_emblem.png` | 512x256 | 3 |
| 18 | Nền màn hình chính | `ui/start_background.png` | 1280x720 | 3 |
| 19 | Bia bắn (mini-game Quán Net) | `minigames/aim_target.png` | 64x64 | 4 |
| 20 | 6 viên bi bida | `minigames/billiard_balls.png` | 192x32 (6 ô 32x32) | 4 |

Giai đoạn 1 đủ để game trông "ra game" (đất, cây, người, đồ). Làm lần lượt 1 → 4.

---

## 2. Khối STYLE và bảng màu (đã nhúng sẵn trong từng prompt)

**Bảng 17 màu duy nhất được dùng:**

| Hex | Vai trò |
|---|---|
| `#2A1F1A` | Viền tối (nâu đen) |
| `#4E3320` | Đất đậm, gỗ tối |
| `#7A5230` | Đất nâu, gỗ |
| `#A67C52` | Gỗ sáng |
| `#C9A66B` | Rơm, mái rạ |
| `#F1E6C8` | Tường vôi kem |
| `#FFF8E7` | Trắng ngà (điểm sáng) |
| `#E8C547` | Vàng lúa |
| `#D9803A` | Cam đất |
| `#B5472F` | Đỏ ngói |
| `#E8B88A` | Màu da |
| `#6FAE3F` | Xanh lá tươi |
| `#5B9A3C` | Xanh cỏ |
| `#2F5D34` | Xanh đậm |
| `#5FA8A8` | Xanh nước ao |
| `#3E5C8A` | Xanh chàm (áo bà ba) |
| `#2B2B33` | Tóc đen, bóng |

**Khối STYLE** (đã có trong mọi prompt bên dưới, ghi ở đây để bạn tham khảo):

```
STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Slight 3/4 top-down view, camera looking down at about 45 degrees. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around characters, props and items; terrain tiles have no outline. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no watermark, no signature.
```

---

## 3. Prompt cho từng asset

> Mỗi khối dưới đây là một prompt hoàn chỉnh. Copy toàn bộ khối.

### Giai đoạn 1

#### 1. Nền đất (`tiles/terrain_tiles.png`)

Dùng cho 4 map và mảnh vườn. Phải **lặp liền mạch** (seamless).

```
Create a pixel-art tileset sheet of 8 square seamless terrain tiles arranged in a clean grid of 4 columns by 2 rows, equal square cells with no gaps and no grid lines drawn. Each tile must tile seamlessly with itself on all four edges. Tiles, left to right, top row then bottom row: (1) plain short grass in #5B9A3C with a few darker #2F5D34 and lighter #6FAE3F pixel tufts; (2) the same grass with a few tiny white #FFF8E7 and yellow #E8C547 wildflowers; (3) packed dirt village path in #C9A66B with small #A67C52 pebbles and #7A5230 specks; (4) freshly tilled farm soil in #7A5230 with parallel darker #4E3320 furrows, ready for planting; (5) wooden plank floor of a village shop, horizontal planks in #A67C52 with #7A5230 gaps and a few knots; (6) market ground of trampled earth in #C9A66B with scattered straw strokes in #E8C547 and a few dark #4E3320 footprints; (7) internet-cafe floor, dark checkered tiles alternating #2B2B33 and #3E5C8A with subtle lighter edges; (8) calm pond water in #5FA8A8 with a few lighter #FFF8E7 ripple pixels. Top-down view, no outlines on terrain, flat colors only. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism, NO 3D rendering. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no watermark, no signature. Final game size will be 48x48 pixels per tile: design the art on a 48x48 pixel grid per tile (each visible pixel block is one art pixel), keep detail simple and bold.
```

#### 2. Cây lúa 3 giai đoạn (`crops/rice_stages.png`)

Vẽ đè lên ô đất cuốc nên **nền trong suốt**.

```
Create a pixel-art sprite strip of a rice plant in 3 growth stages, arranged left to right in a single row of 3 equal square cells with no gaps and no grid lines. Each sprite is centered in its cell and sits at the bottom-center of the cell as if planted in soil. Stage 1: tiny seedling, three short thin bright green #6FAE3F blades. Stage 2: growing rice, a clump of taller green #5B9A3C blades with a few darker #2F5D34 shade pixels, about half the height of the cell. Stage 3: ripe rice ready to harvest, a full clump of tall golden #E8C547 stalks with drooping heavy grain heads, with #D9803A shading and a few green #5B9A3C leaves at the base, nearly filling the cell height. Place all sprites on a solid flat pure magenta #FF00FF background, no shadow on the background, no soil drawn (the soil is a separate tile). STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity. Slight 3/4 top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism. A 1-pixel dark brown outline (#2A1F1A) around each sprite. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no watermark. Final game size will be 32x32 pixels per sprite.
```

#### 3. Player (`characters/player_sheet.png`)

```
Create a pixel-art character sprite sheet of a young Vietnamese rice farmer, arranged in a clean grid of 3 columns by 4 rows with equal cells (each cell is 2:3 portrait), no gaps and no grid lines drawn. Rows from top to bottom: facing DOWN (toward the camera), facing LEFT, facing RIGHT, facing UP (back view). Columns in each row: walk frame with left foot forward, standing neutral frame, walk frame with right foot forward. The character wears a traditional conical palm-leaf hat (non la) in #C9A66B with a darker #A67C52 band, a indigo-blue ao ba ba shirt in #3E5C8A with #FFF8E7 highlights, loose brown trousers in #7A5230, dark #2B2B33 hair visible under the hat, skin tone #E8B88A, and simple bare feet or dark sandals. Friendly, simple, proportions about 3 heads tall, small chibi-like body. The same character design must be identical across all 12 frames, centered in each cell with feet on the same baseline. Place everything on a solid flat pure magenta #FF00FF background with no shadow. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity. Slight 3/4 top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism. A 1-pixel dark brown outline (#2A1F1A) around the character. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no watermark. Final game size will be 32x48 pixels per frame.
```

#### 4. Bà Tư, chủ tạp hóa (`characters/npc_ba_tu.png`)

```
Create a pixel-art character sprite of an elderly Vietnamese grandmother who runs a village grocery shop, facing DOWN toward the camera, shown as 2 idle animation frames side by side in a single row (frame 1 neutral, frame 2 a tiny breathing bob: body 1 pixel higher), equal portrait cells with no gaps and no grid lines. She has gray-white hair in a bun (#FFF8E7 with #C9A66B shading), a brown ao ba ba blouse in #7A5230 with #A67C52 highlights, a dark #2B2B33 skirt, a warm kind smile, skin #E8B88A, small friendly proportions about 3 heads tall like a chibi character. Both frames identical except for the 1-pixel bob, centered, feet on the same baseline. Solid flat pure magenta #FF00FF background, no shadow. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity. Slight 3/4 top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism. A 1-pixel dark brown outline (#2A1F1A). Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no watermark. Final game size will be 32x48 pixels per frame.
```

#### 5. Chú Năm, bán rau ở chợ (`characters/npc_chu_nam.png`)

```
Create a pixel-art character sprite of a cheerful middle-aged Vietnamese man who sells vegetables at a morning market, facing DOWN toward the camera, shown as 2 idle animation frames side by side in a single row (frame 1 neutral, frame 2 a tiny breathing bob: body 1 pixel higher), equal portrait cells with no gaps and no grid lines. He wears a checkered khan ran scarf around his neck in #B5472F and #FFF8E7, a faded green work shirt in #5B9A3C with #2F5D34 shading, brown trousers #7A5230, short dark #2B2B33 hair, skin #E8B88A, a wide friendly smile, small friendly proportions about 3 heads tall like a chibi character. Both frames identical except for the 1-pixel bob, centered, feet on the same baseline. Solid flat pure magenta #FF00FF background, no shadow. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity. Slight 3/4 top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism. A 1-pixel dark brown outline (#2A1F1A). Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no watermark. Final game size will be 32x48 pixels per frame.
```

#### 6. Icon 10 vật phẩm (`icons/item_icons.png`)

Thứ tự ô (trái sang phải, hàng trên rồi hàng dưới) **phải đúng**, vì game ánh xạ theo id:
`lua, hat_giong_lua, mi_tom, cam_ga, xa_phong / rau_muong, ca_chua, bap_cai, trung_ga, dua_leo`.

```
Create a pixel-art inventory icon sheet of 10 items arranged in a clean grid of 5 columns by 2 rows, equal square cells with no gaps and no grid lines drawn, each icon centered with a little padding. Front-facing icon view (not top-down), each item drawn large and readable. Order, left to right, top row then bottom row: (1) a tied bundle of golden rice stalks with grain heads, #E8C547 and #D9803A; (2) a small paper seed packet in #F1E6C8 with a green #6FAE3F sprout drawn on it and a few yellow seeds spilling out; (3) a pack of Vietnamese instant noodles in a red #B5472F and yellow #E8C547 wrapper with a simple bowl picture; (4) a burlap chicken-feed sack in #C9A66B tied at the top with a few yellow #E8C547 grains spilling out; (5) a rectangular bar of laundry soap in #E8C547 with a #FFF8E7 highlight and soft bubbles; (6) a bunch of water spinach (rau muong) with long hollow green stems and arrow-shaped leaves in #6FAE3F and #2F5D34, tied with a string; (7) a ripe red tomato in #B5472F with #D9803A shading and a green #5B9A3C calyx; (8) a round green cabbage in #6FAE3F and #5B9A3C with pale #F1E6C8 vein lines; (9) three brown chicken eggs in #E8B88A and #C9A66B in a small woven straw nest in #A67C52; (10) two green cucumbers in #5B9A3C and #2F5D34 with small bumps and one cut slice showing #F1E6C8 flesh. Solid flat pure magenta #FF00FF background, no shadow. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism. A 1-pixel dark brown outline (#2A1F1A) around every icon. Flat shading with at most 2 shade steps per color. Soft warm light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no letters, no watermark. Final game size will be 64x64 pixels per icon.
```

### Giai đoạn 2

#### 7. Ngôi nhà (`props/house.png`)

```
Create a single pixel-art prop: a small traditional Vietnamese countryside house seen from a slight 3/4 top-down angle (front wall and part of the roof visible), with a clay-tile roof in #B5472F and #D9803A with darker #4E3320 tile lines, whitewashed cream walls in #F1E6C8 with #C9A66B shading, a wooden door in #7A5230, two small shuttered windows in #A67C52, a small porch step and a little pot plant by the door. Cozy and slightly worn. The house is wider than tall (about 3:2) and fully visible inside the image. Solid flat pure magenta #FF00FF background, no ground, no shadow. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity. Slight 3/4 top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism. A 1-pixel dark brown outline (#2A1F1A). Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no watermark. Final game size will be 192x128 pixels.
```

#### 8. Giường có màn (`props/bed.png`)

```
Create a single pixel-art prop: a simple wooden bed with a cream mosquito net (man) hanging over it from four posts, seen from a slight 3/4 top-down angle. Wooden frame #7A5230 and #A67C52, a mat-style mattress with a folded blue #3E5C8A blanket and a white #FFF8E7 pillow, translucent-looking net drawn with light #F1E6C8 vertical stripes (no actual transparency, use flat colors). Roughly square footprint. Solid flat pure magenta #FF00FF background, no shadow. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity. Slight 3/4 top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism. A 1-pixel dark brown outline (#2A1F1A). Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no watermark. Final game size will be 64x64 pixels.
```

#### 9. Quầy tạp hóa (`props/grocery_counter.png`)

```
Create a single pixel-art prop: a long wooden grocery shop counter of a Vietnamese village store seen from a slight 3/4 top-down angle, wider than tall (about 2:1). Counter in #A67C52 and #7A5230. On top: a small abacus-like scale, a glass jar of candies in #D9803A, a stack of instant noodle packs in red #B5472F and yellow #E8C547, a bar of soap, and a small hand-written price board with no readable text (just scribble lines). Behind it a low wooden shelf edge with a few bottles. Warm and cluttered but readable. Solid flat pure magenta #FF00FF background, no shadow. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity. Slight 3/4 top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism. A 1-pixel dark brown outline (#2A1F1A). Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no letters, no watermark. Final game size will be 128x64 pixels.
```

#### 10. Sạp chợ (`props/market_stall.png`)

```
Create a single pixel-art prop: a Vietnamese morning-market vegetable stall seen from a slight 3/4 top-down angle. A sloped tarp canopy awning with red #B5472F and cream #FFF8E7 stripes on four bamboo poles in #A67C52, a low wooden table in #7A5230 below it, and round woven bamboo baskets in #C9A66B filled with leafy green vegetables #6FAE3F, red tomatoes #B5472F, cabbages and eggs, plus a small hanging balance scale. Cheerful and busy but readable. Wider than tall (about 4:3). Solid flat pure magenta #FF00FF background, no shadow. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity. Slight 3/4 top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism. A 1-pixel dark brown outline (#2A1F1A). Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no letters, no watermark. Final game size will be 128x96 pixels.
```

#### 11. Máy tính quán net (`props/net_pc_station.png`)

```
Create a single pixel-art prop: a retro internet-cafe computer station of a Vietnamese village, seen from a slight 3/4 top-down angle. A worn wooden desk in #7A5230, a bulky CRT monitor in #F1E6C8 and #C9A66B glowing with a flat #5FA8A8 screen and a few lighter #FFF8E7 pixel lines, a keyboard, a mouse, a small plastic stool in #3E5C8A in front. Slightly nostalgic early-2000s feel. Wider than tall (about 3:2). Solid flat pure magenta #FF00FF background, no shadow. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity. Slight 3/4 top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism. A 1-pixel dark brown outline (#2A1F1A). Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no letters, no watermark. Final game size will be 96x64 pixels.
```

#### 12. Bàn bida (`props/billiards_table.png`)

```
Create a single pixel-art prop: a village billiards (pool) table seen from a slight 3/4 top-down angle, wider than tall (about 8:5). Wooden rails and legs in #7A5230 and #A67C52, a green felt surface in #2F5D34 with #5B9A3C highlights, six dark #2A1F1A pockets, a few colored balls (red #B5472F, yellow #E8C547, blue #3E5C8A) and one white #FFF8E7 cue ball on the felt, and a cue stick leaning against one side. Solid flat pure magenta #FF00FF background, no shadow. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity. Slight 3/4 top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism. A 1-pixel dark brown outline (#2A1F1A). Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no letters, no watermark. Final game size will be 128x80 pixels.
```

#### 13. Cây cối và đồ trang trí (`props/decor_sheet.png`)

```
Create a pixel-art decoration sheet of 5 props arranged left to right in a single row of 5 equal square cells with no gaps and no grid lines, each prop centered and sitting on a common baseline at the bottom of its cell. Props: (1) a banana tree with broad green leaves #6FAE3F and #2F5D34 and a small hanging bunch of yellow bananas #E8C547; (2) a clump of tall green bamboo stalks #5B9A3C with #2F5D34 nodes and leaf tufts; (3) a round leafy bush #5B9A3C and #2F5D34 with small white #FFF8E7 and pink-orange #D9803A flowers; (4) a short segment of woven bamboo fence in #C9A66B and #A67C52, about one cell wide; (5) a large round clay water jar (chum) in #7A5230 and #A67C52 with a darker rim and a wooden lid. Slight 3/4 top-down view. Solid flat pure magenta #FF00FF background, no shadow. STYLE: 2D top-down pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity. Slight 3/4 top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism. A 1-pixel dark brown outline (#2A1F1A). Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no watermark. Final game size will be 64x64 pixels per prop.
```

### Giai đoạn 3 (giao diện)

#### 14. Khung bảng giấy, 9-slice (`ui/panel_paper.png`)

Dùng làm nền các bảng (cửa hàng, menu, kho đồ). Góc giữ nguyên, cạnh và giữa co giãn, nên giữa phải là màu phẳng.

```
Create a single square pixel-art UI panel frame designed for 9-slice scaling: a warm cream paper panel with a hand-crafted wooden-brown border. The border is 12 pixels thick (at final size), with simple rounded corners and a tiny decorative notch in each corner, border colors #7A5230 and #4E3320 with a #A67C52 highlight line on the top and left inner edge. The inside fill is flat cream #F1E6C8 with very subtle #C9A66B paper speckle pixels only near the edges, and a completely flat plain center area so it can stretch without distortion. Edges between corners must be plain repeatable straight bands. Solid flat pure magenta #FF00FF background outside the panel. STYLE: 2D pixel art UI for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism. A 1-pixel dark brown outline (#2A1F1A) on the outer edge. Flat shading with at most 2 shade steps per color. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no letters, no watermark. Final game size will be 96x96 pixels.
```

#### 15. Nút bấm 3 trạng thái (`ui/buttons.png`)

```
Create a pixel-art UI button sheet showing the SAME wide rounded rectangular button in 3 states stacked vertically in 3 equal rows with no gaps and no grid lines: row 1 NORMAL (wood-brown #A67C52 face with #7A5230 bottom edge and #4E3320 outline), row 2 HOVER (a lighter face #C9A66B with the same edges, slightly brighter), row 3 PRESSED (the face darker #7A5230, shifted 2 pixels down with the bottom edge removed to look pushed in). All three buttons have identical size and shape, rounded corners, a 2-pixel #4E3320 outline, and a plain flat empty center with NO text and NO icon so labels can be added in the game. Solid flat pure magenta #FF00FF background. STYLE: 2D pixel art UI for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism. Flat shading with at most 2 shade steps per color. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no letters, no watermark. Final game size will be 160x48 pixels per button state (160x144 total).
```

#### 16. Icon HUD (`ui/hud_icons.png`)

Thứ tự: đồng xu, đồng hồ, Xuân, Hạ, Thu, Đông, phím E (ô thứ 8 để trống).

```
Create a pixel-art HUD icon sheet of 7 small icons arranged in a clean grid of 4 columns by 2 rows (the eighth cell stays empty), equal square cells with no gaps and no grid lines drawn, each icon centered with padding, front-facing flat icon view. Icons in order, left to right, top row then bottom row: (1) a round old Vietnamese coin in #E8C547 with a square hole and #D9803A shading; (2) a simple round alarm clock in #F1E6C8 with #7A5230 frame and #2A1F1A hands; (3) SPRING: a small pink-orange #D9803A peach blossom branch with green #6FAE3F leaves; (4) SUMMER: a bright #E8C547 sun with short rays; (5) AUTUMN: a falling golden-orange leaf in #D9803A and #E8C547 with a #7A5230 stem; (6) WINTER: a simple snowflake in #FFF8E7 and #5FA8A8 on a cool #3E5C8A round badge; (7) a rounded square keyboard key cap in #F1E6C8 with a thick #7A5230 edge and a bold pixel capital letter E in #2A1F1A. Solid flat pure magenta #FF00FF background, no shadow. STYLE: 2D pixel art UI for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism. A 1-pixel dark brown outline (#2A1F1A) around each icon. Flat shading with at most 2 shade steps per color. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No other text or letters except the single letter E on the key, no watermark. Final game size will be 32x32 pixels per icon.
```

#### 17. Logo, không chữ (`ui/logo_emblem.png`)

Chữ "Hương Quê" sẽ thêm bằng font trong game (AI hay vẽ sai dấu tiếng Việt).

```
Create a pixel-art game logo EMBLEM with NO TEXT: a circular badge in the center showing a golden ripe rice plant with drooping grain heads in front of a rising warm sun (#E8C547 and #D9803A), a small conical palm-leaf hat (non la) resting on the badge's edge, and a few tall bamboo leaves framing the left and right sides in #5B9A3C and #2F5D34. The badge has a #7A5230 wooden-rope border. Leave a clear empty horizontal banner area in plain #F1E6C8 beneath the badge where a title can be added later (completely blank, no letters, no symbols). Wider than tall (2:1). Solid flat pure magenta #FF00FF background, no shadow. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism. A 1-pixel dark brown outline (#2A1F1A). Flat shading with at most 2 shade steps per color. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no letters, no watermark. Final game size will be 512x256 pixels.
```

#### 18. Nền màn hình chính (`ui/start_background.png`)

```
Create a wide pixel-art landscape illustration of a peaceful Vietnamese Red River delta village in spring, 16:9 aspect ratio. Foreground: a calm green rice paddy field with neat rows of young rice in #6FAE3F and #5B9A3C and a narrow dirt path in #C9A66B. Middle: a few traditional houses with clay-tile roofs (#B5472F, #D9803A) and cream walls (#F1E6C8), banana trees, bamboo clumps and a small pond in #5FA8A8. Background: a banyan tree and soft layered hills in #2F5D34 and #3E5C8A under a warm late-afternoon sky in #F1E6C8 fading to #E8C547 near the horizon (stepped flat bands only, no gradient), with a few flat cream clouds. The center of the image should stay calm and relatively empty because menu buttons will be placed over it. Slight top-down 3/4 perspective, cozy, nostalgic, no people. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism. A 1-pixel dark brown outline (#2A1F1A) on houses and trees only. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no letters, no watermark. Final game size will be 1280x720 pixels (the picture should be drawn at a coarse pixel size, as if for a 320x180 canvas scaled up 4x).
```

### Giai đoạn 4 (mini-game)

#### 19. Bia bắn, Quán Net (`minigames/aim_target.png`)

```
Create a single pixel-art game sprite: a round archery-style target with concentric rings in red #B5472F and cream #FFF8E7 with a #E8C547 yellow bullseye in the center, a thin #7A5230 wooden rim, seen straight on (front view), centered and filling most of the image, readable even when small. Solid flat pure magenta #FF00FF background, no shadow. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism. A 1-pixel dark brown outline (#2A1F1A). Flat shading with at most 2 shade steps per color. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no letters, no watermark. Final game size will be 64x64 pixels.
```

#### 20. 6 viên bi bida (`minigames/billiard_balls.png`)

Thứ tự: bi cái trắng, đỏ, vàng, xanh, cam, tím.

```
Create a pixel-art sprite strip of 6 billiard balls arranged left to right in a single row of 6 equal square cells with no gaps and no grid lines, each ball centered and filling most of its cell, seen straight on with a small white #FFF8E7 highlight in the upper-left. Colors in order: (1) cue ball white #FFF8E7 with #C9A66B shading; (2) red #B5472F; (3) yellow #E8C547; (4) blue #3E5C8A; (5) orange #D9803A; (6) deep purple using #2B2B33 darkened toward #3E5C8A. Each ball has a small round white circle on its side with no number or text. Solid flat pure magenta #FF00FF background, no shadow. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO gradients, NO photo-realism. A 1-pixel dark brown outline (#2A1F1A). Flat shading with at most 2 shade steps per color. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. No text, no numbers, no watermark. Final game size will be 32x32 pixels per ball.
```

---

## 4. Sau khi có ảnh: tôi sẽ làm gì trong game

Khi bạn đưa các file đã xử lý vào `assets/art/` đúng đường dẫn ở bảng, tôi sẽ:

- Thay tileset tạo bằng code trong `FarmView` và nền các map bằng `terrain_tiles.png` (TileMapLayer thật).
- Thay hình tròn của Player và NPC bằng sprite có hướng và hoạt ảnh đi bộ (`AnimatedSprite2D`), gắn `icon` vào các file `.tres` vật phẩm để kho đồ và cửa hàng hiện icon thay vì chữ.
- Thay các khối màu của nhà, giường, quầy, sạp, máy tính, bàn bida bằng sprite props.
- Dựng `Theme` giao diện từ khung giấy 9-slice và 3 trạng thái nút, thêm logo và nền cho màn hình chính.
- Cập nhật test và chụp lại ảnh chứng minh trước/sau.

Nếu một sheet ra sai lưới hoặc sai số ô, hãy tạo lại bằng câu: *"Redo it with exactly N columns by M rows of equal cells, one sprite per cell, nothing outside the grid."*
