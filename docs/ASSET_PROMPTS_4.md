# Đợt 4: Giao diện (UI kit)

Làm đầu tiên: giao diện đang là chỗ yếu nhất và mọi màn hình đều dùng chung bộ này.

> Bảng tổng và nguyên tắc chung: [ASSET_CATALOG.md](ASSET_CATALOG.md). Mỗi prompt tự chứa khối STYLE và bảng 17 màu: copy nguyên khối.
> Làm trong cùng một cuộc trò chuyện ChatGPT đã gửi *ảnh neo*, đính kèm ảnh tham chiếu ghi ở mỗi mục nếu có.

| # | Asset | File | Ưu tiên |
|---|---|---|---|
| 42 | Khung ô kho và thanh nhanh | `ui/slots.png` | ★★★ |
| 43 | Bảng 9-slice (8 kiểu) | `ui/panels.png` | ★★★ |
| 44 | Điều khiển nhỏ (nút X, hộp chọn, công tắc...) | `ui/controls.png` | ★★★ |
| 45 | Thanh tiến trình và thể lực | `ui/bars.png` | ★★★ |
| 46 | Tim và sao | `ui/hearts_stars.png` | ★★ |
| 47 | Đồng hồ ngày đêm và lịch | `ui/clock_calendar.png` | ★★ |
| 48 | Icon HUD 2 (hành động) | `ui/hud_icons_2.png` | ★★★ |
| 49 | Icon thời tiết | `ui/weather_icons.png` | ★★ |
| 50 | Icon tab kho đồ | `ui/tab_icons.png` | ★★ |
| 51 | Con trỏ chuột | `ui/cursors.png` | ★★ |
| 52 | Gợi ý phím | `ui/key_hints.png` | ★★ |
| 53 | Bộ cửa hàng và hội thoại | `ui/shop_kit.png` | ★★★ |
| 54 | Bộ nhật ký và bản đồ | `ui/journal_kit.png` | ★★ |
| 55 | Bong bóng cảm xúc | `ui/emotes.png` | ★★ |
| 56 | HUD mini-game | `ui/minigame_hud.png` | ★★ |
| 57 | Màn hình tải | `ui/loading_bg.png` | ★ |
| 58 | Màn hình hết ngày (đi ngủ) | `ui/day_end_bg.png` | ★ |
| 59 | Thẻ bốn mùa | `ui/season_cards.png` | ★ |
| 60 | Họa tiết giấy lặp | `ui/paper_texture.png` | ★ |
| 61 | Bản đồ làng | `ui/world_map_bg.png` | ★ |

---

## 42. Khung ô kho và thanh nhanh (`ui/slots.png`)

Ô kho, thanh nhanh (hotbar) và các trạng thái. Hover/disabled có thể chỉ cần 1 khung rồi làm sáng/tối bằng code, nhưng vẽ sẵn cho đẹp.

*Cỡ ô cuối dự kiến: 64x64 px. Đính kèm tham chiếu: ui/panel_paper.png.*

```
Create a pixel-art UI element sheet arranged in a clean grid of 4 columns by 2 rows (8 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE flat UI element, centered with padding, crisp and symmetrical, no perspective, no text, no letters, no numbers. Cells in reading order (left to right, top row first): (1) empty inventory slot frame: square, recessed dark-brown #4E3320 inner field with a #7A5230 wooden rim, plain empty center; (2) the same slot frame in HOVER state with a brighter #C9A66B rim; (3) the same slot frame in SELECTED state with a thick golden #E8C547 rim and tiny corner notches; (4) the same slot frame in LOCKED state, dimmed, with a small iron padlock in the center; (5) hotbar slot frame with a slightly heavier rim and a small empty plate notch at the top-left corner; (6) hotbar slot frame in SELECTED state with a golden #E8C547 rim and four bright corner brackets; (7) small corner badge: a red #B5472F ribbon marker meaning equipped; (8) small empty rounded plate #F1E6C8 for a quantity number at the bottom-right of a slot. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 64x64 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 43. Bảng 9-slice (8 kiểu) (`ui/panels.png`)

Nền tooltip, ô lõm, giấy ghi chú, bảng phấn (bảng nhiệm vụ), bong bóng thoại, hộp hội thoại, ruy-băng tiêu đề, thanh thông báo.

*Cỡ ô cuối dự kiến: 96x96 px. Đính kèm tham chiếu: ui/panel_paper.png.*

```
Create a pixel-art UI element sheet arranged in a clean grid of 4 columns by 2 rows (8 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE flat UI element, centered with padding, crisp and symmetrical, no perspective, no text, no letters, no numbers. Cells in reading order (left to right, top row first): (1) DARK TOOLTIP panel: dark wood #4E3320 body with a #7A5230 border; (2) INSET LIST panel: a flat #F1E6C8 field with a darker #C9A66B border that looks pressed into the page; (3) NOTE PAPER panel: torn-edge paper #F1E6C8 with a small pin hole at the top center; (4) CHALKBOARD panel: dark green #2F5D34 board in a #A67C52 wooden frame; (5) SPEECH BUBBLE: rounded cream #FFF8E7 bubble with a small tail pointing down at the bottom center; (6) DIALOGUE BOX frame: cream paper with a wood border and a small raised name-tag tab on the top-left edge; (7) TITLE RIBBON: horizontal red #B5472F banner with folded swallowtail ends and a plain flat center; (8) NOTIFICATION TOAST: a slim horizontal cream paper strip with a thin wood border. Every panel is designed for 9-slice scaling: 12-pixel border and corners, plain repeatable straight edges, and a completely flat center without decoration so it can stretch without distortion. Draw each item as wide and tall as its cell allows. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 96x96 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 44. Điều khiển nhỏ (nút X, hộp chọn, công tắc...) (`ui/controls.png`)

Nút đóng 3 trạng thái, hộp chọn, công tắc, núm trượt, nút mũi tên, cộng/trừ.

*Cỡ ô cuối dự kiến: 48x48 px. Đính kèm tham chiếu: ui/buttons.png.*

```
Create a pixel-art UI element sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE flat UI element, centered with padding, crisp and symmetrical, no perspective, no text, no letters, no numbers. Cells in reading order (left to right, top row first): (1) round close button with a pixel X, wood-brown; (2) the same close button in HOVER state, brighter; (3) the same close button in PRESSED state, darker and 1 pixel lower; (4) checkbox UNCHECKED, cream square with wood rim; (5) checkbox CHECKED with a green #5B9A3C tick; (6) toggle switch OFF, wooden knob on the left of a grey-brown pill; (7) toggle switch ON, wooden knob on the right of a green #6FAE3F pill; (8) round slider knob in wood; (9) left arrow button, small wood square with a cream left triangle; (10) right arrow button, small wood square with a cream right triangle; (11) plus button, small wood square with a cream plus sign; (12) minus button, small wood square with a cream minus sign. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 48x48 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 45. Thanh tiến trình và thể lực (`ui/bars.png`)

Khung và phần lấp đầy tách rời để game cắt theo giá trị. Dùng cho thể lực, tiến trình, hẹn giờ, thanh trượt, thanh cuộn.

*Cỡ ô cuối dự kiến: 192x32 px. Đính kèm tham chiếu: ui/buttons.png.*

```
Create a pixel-art UI element sheet arranged in a clean grid of 2 columns by 4 rows (8 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE flat UI element, centered with padding, crisp and symmetrical, no perspective, no text, no letters, no numbers. Cells in reading order (left to right, top row first): (1) empty horizontal PROGRESS BAR frame: wooden rounded rim #7A5230 around a dark #2A1F1A recessed empty track; (2) matching green #6FAE3F progress FILL strip, same size, drawn on its own with a lighter top line; (3) empty STAMINA BAR frame in the same style with a small leaf emblem at the left end; (4) matching warm yellow #E8C547 stamina FILL strip; (5) empty TIMER BAR frame with a small clock emblem at the left end; (6) matching red #B5472F timer FILL strip; (7) thin SLIDER TRACK groove in wood with rounded ends; (8) horizontal SCROLLBAR track with a wooden thumb handle in the middle. Frame images and fill images must have exactly the same size and alignment so the fill can sit inside the frame. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 192x32 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 46. Tim và sao (`ui/hearts_stars.png`)

Độ thân thiết với dân làng, xếp hạng sao mini-game.

*Cỡ ô cuối dự kiến: 32x32 px. Đính kèm tham chiếu: ui/hud_icons.png.*

```
Create a pixel-art UI element sheet arranged in a clean grid of 4 columns by 2 rows (8 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE flat UI element, centered with padding, crisp and symmetrical, no perspective, no text, no letters, no numbers. Cells in reading order (left to right, top row first): (1) red #B5472F heart, full; (2) heart, half full; (3) heart, empty outline only; (4) heart in LOCKED state, greyed with a tiny lock; (5) golden #E8C547 star, filled; (6) star, half filled; (7) star, empty outline only; (8) small sparkle badge, four-point star in #FFF8E7 and #E8C547. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 32x32 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 47. Đồng hồ ngày đêm và lịch (`ui/clock_calendar.png`)

Mặt đồng hồ ngày đêm, kim, tờ lịch trống (số do game vẽ), dấu hôm nay, cờ lễ hội, bánh sinh nhật.

*Cỡ ô cuối dự kiến: 128x128 px. Đính kèm tham chiếu: ui/hud_icons.png.*

```
Create a pixel-art UI element sheet arranged in a clean grid of 3 columns by 2 rows (6 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE flat UI element, centered with padding, crisp and symmetrical, no perspective, no text, no letters, no numbers. Cells in reading order (left to right, top row first): (1) round DAY-NIGHT DIAL frame: a wooden ring whose upper half shows a #5FA8A8 daytime band with a tiny sun marker and whose lower half shows a #3E5C8A night band with a tiny moon, with the center left plain; fill the area outside the ring with magenta; (2) dial HAND: a slim pointer arrow with a round hub, drawn alone, pointing straight up; (3) CALENDAR PAGE frame: portrait paper sheet with a wooden hanger at the top, a header band, and an EMPTY 7-column by 5-row date grid drawn with thin lines, no numbers; (4) TODAY marker: a red #B5472F circle outline for circling a date, with the inside filled magenta; (5) FESTIVAL marker: a small yellow #E8C547 flag on a stick; (6) BIRTHDAY marker: a small cake with a single candle. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 128x128 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 48. Icon HUD 2 (hành động) (`ui/hud_icons_2.png`)

Túi đồ, nhật ký, bản đồ, cài đặt, lưu, tải, nhà, ngủ, chuông, âm thanh bật/tắt, trợ giúp.

*Cỡ ô cuối dự kiến: 32x32 px. Đính kèm tham chiếu: ui/hud_icons.png.*

```
Create a pixel-art item icon sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE icon: a single object, centered, filling about 70 percent of the cell, with a clear silhouette that stays recognizable at small size. Cells in reading order (left to right, top row first): (1) woven bag (inventory); (2) journal notebook with a ribbon bookmark; (3) rolled map scroll; (4) wooden gear (settings); (5) closed ledger book with a seal (save); (6) open book (load); (7) small house (home); (8) bed with pillow (sleep); (9) brass bell (notification); (10) speaker with sound waves (sound on); (11) speaker with a cross (muted); (12) round question-mark badge (help). Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view with a very slight top-down tilt, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 32x32 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 49. Icon thời tiết (`ui/weather_icons.png`)

Dự báo thời tiết trên HUD, 12 trạng thái.

*Cỡ ô cuối dự kiến: 32x32 px. Đính kèm tham chiếu: ui/hud_icons.png.*

```
Create a pixel-art item icon sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE icon: a single object, centered, filling about 70 percent of the cell, with a clear silhouette that stays recognizable at small size. Cells in reading order (left to right, top row first): (1) sunny: a bright sun; (2) partly cloudy: sun behind a cloud; (3) cloudy: two grey-cream clouds; (4) light rain: cloud with a few drops; (5) heavy rain: dark cloud with many streaks; (6) thunderstorm: dark cloud with a yellow lightning bolt; (7) fog: layered horizontal mist bands; (8) windy: swirling wind lines with a leaf; (9) hot day: sun with a thermometer; (10) cold day: snowflake with a thermometer; (11) night: crescent moon with two stars; (12) rainbow after rain. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view with a very slight top-down tilt, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 32x32 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 50. Icon tab kho đồ (`ui/tab_icons.png`)

Các tab phân loại trong kho đồ và cửa hàng.

*Cỡ ô cuối dự kiến: 32x32 px. Đính kèm tham chiếu: ui/hud_icons.png.*

```
Create a pixel-art item icon sheet arranged in a clean grid of 4 columns by 2 rows (8 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE icon: a single object, centered, filling about 70 percent of the cell, with a clear silhouette that stays recognizable at small size. Cells in reading order (left to right, top row first): (1) woven bag (all items); (2) crossed hoe and watering can (tools); (3) seed packet (seeds); (4) carrot and cabbage (crops); (5) fish (fish); (6) steaming bowl (cooked food); (7) wood log and stone (materials); (8) wrapped gift (gifts). Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view with a very slight top-down tilt, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 32x32 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 51. Con trỏ chuột (`ui/cursors.png`)

Con trỏ tuỳ chỉnh. Điểm nóng (hotspot) nằm ở góc trên-trái của mũi tên/ngón tay.

*Cỡ ô cuối dự kiến: 32x32 px. Đính kèm tham chiếu: ui/hud_icons.png.*

```
Create a pixel-art UI element sheet arranged in a clean grid of 4 columns by 2 rows (8 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE flat UI element, centered with padding, crisp and symmetrical, no perspective, no text, no letters, no numbers. Cells in reading order (left to right, top row first): (1) arrow pointer, tip at the top-left corner, cream with dark outline; (2) pointing hand, fingertip near the top-left; (3) open hand (grab available); (4) closed fist (grabbing); (5) speech-bubble cursor (talk); (6) magnifying-glass cursor (inspect); (7) square target reticle (use tool here); (8) red X in a circle (not allowed). Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 32x32 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 52. Gợi ý phím (`ui/key_hints.png`)

Phím trống, chữ do game vẽ lên (E, Esc, I...). Tránh để AI vẽ chữ.

*Cỡ ô cuối dự kiến: 32x32 px. Đính kèm tham chiếu: ui/hud_icons.png.*

```
Create a pixel-art UI element sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE flat UI element, centered with padding, crisp and symmetrical, no perspective, no text, no letters, no numbers. Cells in reading order (left to right, top row first): (1) blank square keycap, raised; (2) blank square keycap, pressed down; (3) wide blank keycap (for Space or Shift), raised; (4) wide blank keycap, pressed down; (5) mouse with the LEFT button highlighted in #E8C547; (6) mouse with the RIGHT button highlighted; (7) mouse with the scroll wheel highlighted; (8) four blank keycaps in a WASD cross layout; (9) four blank arrow keycaps in an inverted-T layout; (10) gamepad A button, round green; (11) gamepad B button, round red; (12) gamepad D-pad cross. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 32x32 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 53. Bộ cửa hàng và hội thoại (`ui/shop_kit.png`)

Thẻ giá, xu, tem hết hàng, nhãn mới/giảm giá, nút lựa chọn hội thoại, bảng tên, mũi tên tiếp tục, ô số lượng.

*Cỡ ô cuối dự kiến: 128x64 px. Đính kèm tham chiếu: ui/panel_paper.png.*

```
Create a pixel-art UI element sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE flat UI element, centered with padding, crisp and symmetrical, no perspective, no text, no letters, no numbers. Cells in reading order (left to right, top row first): (1) wooden PRICE TAG with a string loop, plain empty face; (2) small stack of old round coins with square holes; (3) SOLD-OUT stamp: a diagonal red #B5472F band with no text; (4) NEW badge: yellow #E8C547 starburst, no text; (5) DISCOUNT badge: red #B5472F starburst, no text; (6) CHOICE button frame, wide wood-and-paper, normal; (7) CHOICE button frame, HOVER state, brighter; (8) NAME TAG plate: small cream banner with a wooden pin; (9) CONTINUE indicator: a small downward-pointing triangle in wood; (10) QUANTITY STEPPER frame: a wide rounded pill with space for a number between two small square buttons; (11) round COUNT BADGE in red #B5472F, plain; (12) LOCK tag: small padlock on a wooden plate. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 128x64 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 54. Bộ nhật ký và bản đồ (`ui/journal_kit.png`)

Trang nhật ký, nhãn đánh dấu, dấu nhiệm vụ, ghim bản đồ.

*Cỡ ô cuối dự kiến: 64x64 px. Đính kèm tham chiếu: ui/panel_paper.png.*

```
Create a pixel-art UI element sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE flat UI element, centered with padding, crisp and symmetrical, no perspective, no text, no letters, no numbers. Cells in reading order (left to right, top row first): (1) portrait notebook PAGE: cream paper with faint ruled lines and a wood-colored top binding; (2) bookmark tab, red #B5472F; (3) bookmark tab, blue #3E5C8A; (4) bookmark tab, green #5B9A3C; (5) green tick STAMP, round; (6) quest marker: a yellow #E8C547 exclamation mark badge (new quest); (7) quest marker: a grey question-mark badge (in progress); (8) quest marker: a green #5B9A3C checkmark badge (complete); (9) map pin: PLAYER, a red pin with a tiny conical hat; (10) map pin: SHOP, a blue pin with a tiny bag; (11) map pin: HOME, a brown pin with a tiny house; (12) map pin: LOCKED, a grey pin with a padlock. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 64x64 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 55. Bong bóng cảm xúc (`ui/emotes.png`)

Cảm xúc nhỏ hiện trên đầu nhân vật. Bóng thoại tròn kèm đuôi nhỏ ở dưới.

*Cỡ ô cuối dự kiến: 32x32 px. Đính kèm tham chiếu: ui/hud_icons.png.*

```
Create a pixel-art UI element sheet arranged in a clean grid of 4 columns by 3 rows (12 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE flat UI element, centered with padding, crisp and symmetrical, no perspective, no text, no letters, no numbers. Cells in reading order (left to right, top row first): (1) heart in a speech bubble; (2) angry vein mark in a speech bubble; (3) question mark in a speech bubble; (4) exclamation mark in a speech bubble; (5) sweat drop in a speech bubble; (6) music note in a speech bubble; (7) ZZZ sleep marks in a speech bubble; (8) light bulb idea in a speech bubble; (9) coin in a speech bubble; (10) hungry bowl in a speech bubble; (11) sad rain cloud in a speech bubble; (12) happy smiling face in a speech bubble. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 32x32 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 56. HUD mini-game (`ui/minigame_hud.png`)

Khung đồng hồ, điểm, combo, kết quả sao, các nhãn mini-game chung.

*Cỡ ô cuối dự kiến: 96x64 px. Đính kèm tham chiếu: ui/panel_paper.png.*

```
Create a pixel-art UI element sheet arranged in a clean grid of 4 columns by 2 rows (8 equal-size cells), no gaps between cells, no grid lines, no cell numbers or labels drawn. Each cell contains exactly ONE flat UI element, centered with padding, crisp and symmetrical, no perspective, no text, no letters, no numbers. Cells in reading order (left to right, top row first): (1) TIMER plate: wooden rounded plate with a small clock icon at the left and an empty area for numbers; (2) SCORE plate: wooden rounded plate with a small coin icon at the left and an empty area for numbers; (3) COMBO badge: yellow #E8C547 starburst, plain; (4) RESULT star banner: red ribbon holding three empty star sockets; (5) READY / GO plate: wide wooden plate, plain empty face; (6) ROUND counter pill: small cream pill, plain; (7) PAUSE badge: round wooden button with two pause bars; (8) QUIT badge: round wooden button with a small door arrow. Place everything on a solid flat pure magenta #FF00FF background with no shadow, no gradient and no grid lines. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Flat front-facing view, no perspective. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. A 1-pixel dark brown outline (#2A1F1A) around every item. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 96x64 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 57. Màn hình tải (`ui/loading_bg.png`)

Ảnh nền cho màn hình tải/chuyển cảnh. Chừa phần dưới yên tĩnh.

*Cỡ ô cuối dự kiến: 1280x720 px. Đính kèm tham chiếu: ui/start_background.png.*

```
Create a single pixel-art pixel-art illustration: a cozy dusk view of a Red River delta village: golden rice paddies in the foreground, a small tiled house with a warm lit window, bamboo grove, a water buffalo silhouette, distant hills, first stars appearing. Keep the lower third calm and low-detail so a progress bar can sit there. A complete wide 16:9 landscape scene with rich but readable pixel detail, using stepped color bands instead of smooth gradients, no close-up faces. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Wide 16:9 landscape composition. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. No outlines; separate shapes with a darker shade of the same color instead. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 1280x720 pixels: design the art on that pixel grid with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 58. Màn hình hết ngày (đi ngủ) (`ui/day_end_bg.png`)

Hiện khi sang ngày mới / đi ngủ.

*Cỡ ô cuối dự kiến: 1280x720 px. Đính kèm tham chiếu: ui/start_background.png.*

```
Create a single pixel-art pixel-art illustration: a night view through an open wooden window with shutters: a large moon, fireflies, silhouettes of palm and bamboo, a cup of tea and an oil lamp on the windowsill, soft blue #3E5C8A night tones with a warm #E8C547 lamp glow. Leave the center area calm for text. A complete wide 16:9 landscape scene with rich but readable pixel detail, using stepped color bands instead of smooth gradients, no close-up faces. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Wide 16:9 landscape composition. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. No outlines; separate shapes with a darker shade of the same color instead. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 1280x720 pixels: design the art on that pixel grid with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 59. Thẻ bốn mùa (`ui/season_cards.png`)

Bốn tranh cho banner đầu mùa. Ghép trong một ảnh 2x2.

*Cỡ ô cuối dự kiến: 640x360 px. Đính kèm tham chiếu: ui/start_background.png.*

```
Create a pixel-art pixel-art illustration arranged in a clean grid of 2 columns by 2 rows (4 equal-size cells), each cell a complete 16:9 landscape picture, no gaps between cells, no grid lines, no cell numbers or labels drawn. A complete wide 16:9 landscape scene with rich but readable pixel detail, using stepped color bands instead of smooth gradients, no close-up faces. Cells in reading order (left to right, top row first): (1) SPRING: peach blossom branches over a green paddy, soft sunrise; (2) SUMMER: lotus pond under a bright sun, dragonflies; (3) AUTUMN: golden rice harvest with sheaves and a straw hat; (4) WINTER: misty cold morning, bare tree, a red scarf on a fence. The four panels have an equal 16:9 shape and are separated by thin flat pure magenta #FF00FF gaps. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Wide 16:9 landscape composition. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. No outlines; separate shapes with a darker shade of the same color instead. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 640x360 pixels per cell: design the art as if drawn on that pixel grid per cell, with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 60. Họa tiết giấy lặp (`ui/paper_texture.png`)

Nền lặp cho menu/tờ giấy, thay màu phẳng.

*Cỡ ô cuối dự kiến: 128x128 px. Đính kèm tham chiếu: ui/panel_paper.png.*

```
Create a single pixel-art seamless texture tile: warm cream #F1E6C8 paper with very faint fiber specks in #C9A66B and a few tiny #FFF8E7 highlights. A single square texture that tiles seamlessly on all four edges, very subtle, no focal point. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Strict top-down view. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. No outlines; separate shapes with a darker shade of the same color instead. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 128x128 pixels: design the art on that pixel grid with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```

## 61. Bản đồ làng (`ui/world_map_bg.png`)

Nền cho màn hình bản đồ. Bố cục chỉ mang tính gợi ý theo các map hiện có.

*Cỡ ô cuối dự kiến: 1280x720 px. Đính kèm tham chiếu: ui/panel_paper.png.*

```
Create a single pixel-art pixel-art illustration: a hand-drawn pixel-art map of a small Vietnamese village on aged parchment with a wooden border: a house with a garden at the center-left, a grocery shop to the north, a morning market to the east, an entertainment street with a net cafe and a billiard hall to the south-east, a river with a small bridge, dirt paths connecting them, tiny trees. Leave a blank scroll cartouche at the top for the title. No labels. A complete wide 16:9 landscape scene with rich but readable pixel detail, using stepped color bands instead of smooth gradients, no close-up faces. STYLE: 2D pixel art for a cozy Vietnamese countryside life-sim, inspired by the feel of Stardew Valley but with its own identity (Red River delta village, sunny spring). Wide 16:9 landscape composition. Chunky, clearly visible pixels, crisp hard edges, NO anti-aliasing, NO blur, NO smooth gradients, NO photo-realism, NO 3D rendering. No outlines; separate shapes with a darker shade of the same color instead. Flat shading with at most 2 shade steps per color. Soft warm afternoon light from the top-left. Use ONLY this limited warm earthy palette: #2A1F1A #4E3320 #7A5230 #A67C52 #C9A66B #F1E6C8 #FFF8E7 #E8C547 #D9803A #B5472F #E8B88A #6FAE3F #5B9A3C #2F5D34 #5FA8A8 #3E5C8A #2B2B33. Mood: warm, peaceful, nostalgic. No text, no letters, no numbers, no watermark, no signature. Final game size will be 1280x720 pixels: design the art on that pixel grid with simple bold shapes. If a reference image is attached, match its exact style, palette, outline and pixel density; if none is attached, follow this prompt alone.
```
