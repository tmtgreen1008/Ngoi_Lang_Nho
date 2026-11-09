# Danh mục asset tổng của Hương Quê (làm một lần cho xong)

Tài liệu này liệt kê **toàn bộ** ảnh pixel-art cần để game đủ đa dạng, từ giao diện, vật phẩm, địa hình, ngoại cảnh, nội thất, lễ hội, nhân vật, vật nuôi tới hiệu ứng và mini-game. Prompt hoàn chỉnh của từng ảnh nằm trong các file đợt tương ứng (bảng bên dưới có liên kết).

> File này và các file `ASSET_PROMPTS_4.md` đến `ASSET_PROMPTS_9.md` được sinh từ một danh sách duy nhất, nên số thứ tự, tên file, cỡ ô và prompt luôn khớp nhau.

## 1. Tổng quan

| Đợt | Nội dung | Số ảnh | Trạng thái |
|---|---|---|---|
| 1 | Nền đất, cây lúa, Player, 2 NPC, icon, nhà, đồ dùng, UI cơ bản, mini-game (#1-20) | 20 | ✅ Đã có và đã nối vào game |
| 2 | Đồ lặt vặt, dây phơi, biển chỉ đường, nội thất, ô nền bổ sung (#21-25) | 5 | 📝 Có prompt ([ASSET_PROMPTS_2.md](ASSET_PROMPTS_2.md)), chờ ảnh |
| 3 | Chuồng trại, ao, sạp chợ, xóm làng, khu giải trí (#26-41) | 16 | 📝 Có prompt ([ASSET_PROMPTS_3.md](ASSET_PROMPTS_3.md)), chờ ảnh |
| 4 | Giao diện (UI kit) | 20 | 🆕 Prompt mới ([ASSET_PROMPTS_4.md](ASSET_PROMPTS_4.md)) |
| 5 | Vật phẩm và cây trồng | 15 | 🆕 Prompt mới ([ASSET_PROMPTS_5.md](ASSET_PROMPTS_5.md)) |
| 6 | Địa hình, cây cối và ngoại cảnh | 21 | 🆕 Prompt mới ([ASSET_PROMPTS_6.md](ASSET_PROMPTS_6.md)) |
| 7 | Nội thất, trang trí và lễ hội | 11 | 🆕 Prompt mới ([ASSET_PROMPTS_7.md](ASSET_PROMPTS_7.md)) |
| 8 | Nhân vật và vật nuôi | 25 | 🆕 Prompt mới ([ASSET_PROMPTS_8.md](ASSET_PROMPTS_8.md)) |
| 9 | Hiệu ứng và mini-game | 9 | 🆕 Prompt mới ([ASSET_PROMPTS_9.md](ASSET_PROMPTS_9.md)) |

**Tổng cộng: 142 ảnh/sheet** (20 đã có, 21 đã có prompt, 101 prompt mới).

Ưu tiên: ★★★ cần ngay (game thiếu là thấy), ★★ nên có, ★ làm đẹp/để dành.

## 2. Nguyên tắc để làm đúng ngay lần đầu

1. **Một cuộc trò chuyện ChatGPT duy nhất cho một đợt**, và bắt đầu bằng việc gửi *ảnh neo* (xem mục 3).
2. Mỗi prompt đã chứa khối STYLE và bảng 17 màu, dán nguyên văn. Câu cuối cho phép chạy cả khi quên đính kèm ảnh tham chiếu.
3. **Sheet nhỏ (4x3 ô trở xuống)** cho kết quả ổn định hơn sheet lớn. Nếu AI vẽ thừa/thiếu ô, tạo lại thay vì cắt tay.
4. **Đừng để AI vẽ chữ**: biển hiệu, lịch, thẻ giá đều để trống; chữ do game vẽ.
5. Tải **ảnh gốc** (nút tải xuống), đặt vào `assets/art/source/` và báo tôi. Tôi đo cỡ pixel, cắt bằng `tools/slice_sheet.gd`, đưa về bảng màu và nối vào game.
6. Cột *Đính kèm* ghi ảnh đã duyệt nên đính kèm để giữ mật độ pixel (không bắt buộc).
7. Trạng thái nút/ô (hover, nhấn, tối) có thể làm bằng code từ một ảnh, nên không phải ảnh nào cũng cần đủ biến thể.

## 3. Ảnh neo phong cách (làm trước tiên, một lần)

Ghép 4 ảnh đã duyệt tốt nhất (`ui/panel_paper.png`, `characters/player_sheet.png`, `icons/item_icons.png`, `tiles/terrain_tiles.png`) vào **một ảnh** rồi gửi vào ChatGPT kèm câu:

```
This is the style anchor for a whole game. Remember its exact pixel density, palette, 1-pixel dark outline and flat shading. For every following request, produce art that looks like it was drawn by the same artist on the same pixel grid. Reply only with OK.
```

## 4. Thứ tự đề xuất

1. Đợt 4 (giao diện) phần ★★★: `ui/slots`, `ui/panels`, `ui/controls`, `ui/bars`, `ui/hud_icons_2`, `ui/shop_kit`.
2. Đợt 5 phần ★★★: công cụ, hạt giống, nông sản A, cây trồng lớn lên A.
3. Đợt 6 phần ★★★: đất canh tác, bờ nước, cây lớn, hàng rào (cùng đợt 2 và 3 cho các map).
4. Đợt 8 phần ★★★: hành động cuốc/tưới, gà, lợn.
5. Phần còn lại theo sở thích: nội thất, lễ hội, hiệu ứng, mini-game.

## 5. Danh sách đầy đủ

### Đợt 1 (đã có)

| # | Asset | File (trong `assets/art/`) |
|---|---|---|
| 1 | Nền đất (8 ô) | `tiles/terrain_tiles.png` |
| 2 | Cây lúa 3 giai đoạn | `crops/rice_stages.png` |
| 3 | Player 4 hướng | `characters/player_sheet.png` |
| 4 | Bà Tư | `characters/npc_ba_tu.png` |
| 5 | Chú Năm | `characters/npc_chu_nam.png` |
| 6 | Icon 10 vật phẩm | `icons/item_icons.png` |
| 7 | Ngôi nhà | `props/house.png` |
| 8 | Giường | `props/bed.png` |
| 9 | Quầy tạp hóa | `props/grocery_counter.png` |
| 10 | Sạp chợ | `props/market_stall.png` |
| 11 | Máy tính quán net | `props/net_pc_station.png` |
| 12 | Bàn bida | `props/billiards_table.png` |
| 13 | Cây cối, hàng rào | `props/decor_sheet.png` |
| 14 | Khung bảng giấy | `ui/panel_paper.png` |
| 15 | Nút bấm 3 trạng thái | `ui/buttons.png` |
| 16 | Icon HUD | `ui/hud_icons.png` |
| 17 | Logo | `ui/logo_emblem.png` |
| 18 | Nền màn hình chính | `ui/start_background.png` |
| 19 | Bia bắn | `minigames/aim_target.png` |
| 20 | Bi bida | `minigames/billiard_balls.png` |

### Đợt 2 và 3 (đã có prompt, chờ ảnh)

| # | Asset | File | Prompt |
|---|---|---|---|
| 21 | Đồ lặt vặt ngoài sân | `props/clutter_sheet.png` | [ASSET_PROMPTS_2.md](ASSET_PROMPTS_2.md) |
| 22 | Dây phơi | `props/clothesline.png` | [ASSET_PROMPTS_2.md](ASSET_PROMPTS_2.md) |
| 23 | Biển chỉ đường | `props/signposts.png` | [ASSET_PROMPTS_2.md](ASSET_PROMPTS_2.md) |
| 24 | Nội thất trong nhà | `props/interior_sheet.png` | [ASSET_PROMPTS_2.md](ASSET_PROMPTS_2.md) |
| 25 | Ô nền bổ sung | `tiles/terrain_extra.png` | [ASSET_PROMPTS_2.md](ASSET_PROMPTS_2.md) |
| 26 | Chuồng trại | `props/farm_buildings.png` | [ASSET_PROMPTS_3.md](ASSET_PROMPTS_3.md) |
| 27 | Ao làng | `props/pond.png` | [ASSET_PROMPTS_3.md](ASSET_PROMPTS_3.md) |
| 28 | Đồ sân vườn | `props/yard_props.png` | [ASSET_PROMPTS_3.md](ASSET_PROMPTS_3.md) |
| 29 | Vật nuôi (tĩnh) | `props/animals.png` | [ASSET_PROMPTS_3.md](ASSET_PROMPTS_3.md) |
| 30 | Sạp chợ 6 kiểu | `props/market_stalls.png` | [ASSET_PROMPTS_3.md](ASSET_PROMPTS_3.md) |
| 31 | Đồ chợ lặt vặt | `props/market_clutter.png` | [ASSET_PROMPTS_3.md](ASSET_PROMPTS_3.md) |
| 32 | Cổng chợ, mái chợ | `props/market_gate.png` | [ASSET_PROMPTS_3.md](ASSET_PROMPTS_3.md) |
| 33 | Ô nền chợ | `tiles/market_tiles.png` | [ASSET_PROMPTS_3.md](ASSET_PROMPTS_3.md) |
| 34 | Người dân (6) | `characters/villagers.png` | [ASSET_PROMPTS_3.md](ASSET_PROMPTS_3.md) |
| 35 | Nhà dân ở xóm | `props/village_houses.png` | [ASSET_PROMPTS_3.md](ASSET_PROMPTS_3.md) |
| 36 | Mặt tiền Tiệm Tạp Hóa | `props/grocery_facade.png` | [ASSET_PROMPTS_3.md](ASSET_PROMPTS_3.md) |
| 37 | Đồ xóm làng | `props/village_props.png` | [ASSET_PROMPTS_3.md](ASSET_PROMPTS_3.md) |
| 38 | Ô nền xóm làng | `tiles/village_tiles.png` | [ASSET_PROMPTS_3.md](ASSET_PROMPTS_3.md) |
| 39 | Mặt tiền Quán Net, Quán Bida | `props/entertainment_facades.png` | [ASSET_PROMPTS_3.md](ASSET_PROMPTS_3.md) |
| 40 | Đồ giải trí ngoài trời | `props/leisure_props.png` | [ASSET_PROMPTS_3.md](ASSET_PROMPTS_3.md) |
| 41 | Ô nền khu giải trí | `tiles/leisure_tiles.png` | [ASSET_PROMPTS_3.md](ASSET_PROMPTS_3.md) |

### Đợt 4: Giao diện (UI kit)

Làm đầu tiên: giao diện đang là chỗ yếu nhất và mọi màn hình đều dùng chung bộ này. Prompt: [ASSET_PROMPTS_4.md](ASSET_PROMPTS_4.md).

| # | Asset | File | Ô | Cỡ ô cuối | Ưu tiên | Đính kèm |
|---|---|---|---|---|---|---|
| 42 | Khung ô kho và thanh nhanh | `ui/slots.png` | 8 (4x2) | 64x64 | ★★★ | ui/panel_paper.png |
| 43 | Bảng 9-slice (8 kiểu) | `ui/panels.png` | 8 (4x2) | 96x96 | ★★★ | ui/panel_paper.png |
| 44 | Điều khiển nhỏ (nút X, hộp chọn, công tắc...) | `ui/controls.png` | 12 (4x3) | 48x48 | ★★★ | ui/buttons.png |
| 45 | Thanh tiến trình và thể lực | `ui/bars.png` | 8 (2x4) | 192x32 | ★★★ | ui/buttons.png |
| 46 | Tim và sao | `ui/hearts_stars.png` | 8 (4x2) | 32x32 | ★★ | ui/hud_icons.png |
| 47 | Đồng hồ ngày đêm và lịch | `ui/clock_calendar.png` | 6 (3x2) | 128x128 | ★★ | ui/hud_icons.png |
| 48 | Icon HUD 2 (hành động) | `ui/hud_icons_2.png` | 12 (4x3) | 32x32 | ★★★ | ui/hud_icons.png |
| 49 | Icon thời tiết | `ui/weather_icons.png` | 12 (4x3) | 32x32 | ★★ | ui/hud_icons.png |
| 50 | Icon tab kho đồ | `ui/tab_icons.png` | 8 (4x2) | 32x32 | ★★ | ui/hud_icons.png |
| 51 | Con trỏ chuột | `ui/cursors.png` | 8 (4x2) | 32x32 | ★★ | ui/hud_icons.png |
| 52 | Gợi ý phím | `ui/key_hints.png` | 12 (4x3) | 32x32 | ★★ | ui/hud_icons.png |
| 53 | Bộ cửa hàng và hội thoại | `ui/shop_kit.png` | 12 (4x3) | 128x64 | ★★★ | ui/panel_paper.png |
| 54 | Bộ nhật ký và bản đồ | `ui/journal_kit.png` | 12 (4x3) | 64x64 | ★★ | ui/panel_paper.png |
| 55 | Bong bóng cảm xúc | `ui/emotes.png` | 12 (4x3) | 32x32 | ★★ | ui/hud_icons.png |
| 56 | HUD mini-game | `ui/minigame_hud.png` | 8 (4x2) | 96x64 | ★★ | ui/panel_paper.png |
| 57 | Màn hình tải | `ui/loading_bg.png` | 1 (1x1) | 1280x720 | ★ | ui/start_background.png |
| 58 | Màn hình hết ngày (đi ngủ) | `ui/day_end_bg.png` | 1 (1x1) | 1280x720 | ★ | ui/start_background.png |
| 59 | Thẻ bốn mùa | `ui/season_cards.png` | 4 (2x2) | 640x360 | ★ | ui/start_background.png |
| 60 | Họa tiết giấy lặp | `ui/paper_texture.png` | 1 (1x1) | 128x128 | ★ | ui/panel_paper.png |
| 61 | Bản đồ làng | `ui/world_map_bg.png` | 1 (1x1) | 1280x720 | ★ | ui/panel_paper.png |

### Đợt 5: Vật phẩm và cây trồng

Icon mọi vật phẩm trong kho đồ/cửa hàng và hình các giai đoạn lớn của cây trồng. Prompt: [ASSET_PROMPTS_5.md](ASSET_PROMPTS_5.md).

| # | Asset | File | Ô | Cỡ ô cuối | Ưu tiên | Đính kèm |
|---|---|---|---|---|---|---|
| 62 | Công cụ (cơ bản) | `icons/tools_basic.png` | 12 (4x3) | 64x64 | ★★★ | icons/item_icons.png |
| 63 | Công cụ (nâng cấp) | `icons/tools_upgrade.png` | 12 (4x3) | 64x64 | ★ | icons/tools_basic.png |
| 64 | Hạt giống | `icons/seeds.png` | 12 (4x3) | 64x64 | ★★★ | icons/item_icons.png |
| 65 | Nông sản A | `icons/crops_a.png` | 12 (4x3) | 64x64 | ★★★ | icons/item_icons.png |
| 66 | Nông sản B (trái cây, hoa, đặc sản) | `icons/crops_b.png` | 12 (4x3) | 64x64 | ★★ | icons/item_icons.png |
| 67 | Sản phẩm vật nuôi | `icons/animal_products.png` | 12 (4x3) | 64x64 | ★★ | icons/item_icons.png |
| 68 | Cá và thủy sản | `icons/fish.png` | 12 (4x3) | 64x64 | ★★ | icons/item_icons.png |
| 69 | Món ăn A | `icons/food_a.png` | 12 (4x3) | 64x64 | ★★ | icons/item_icons.png |
| 70 | Món ăn B và đồ uống | `icons/food_b.png` | 12 (4x3) | 64x64 | ★ | icons/item_icons.png |
| 71 | Nguyên liệu | `icons/materials.png` | 12 (4x3) | 64x64 | ★★ | icons/item_icons.png |
| 72 | Hàng tạp hóa | `icons/goods.png` | 12 (4x3) | 64x64 | ★★ | icons/item_icons.png |
| 73 | Đồ sưu tầm và quà | `icons/collectibles.png` | 12 (4x3) | 64x64 | ★ | icons/item_icons.png |
| 74 | Cây trồng lớn lên A | `crops/growth_a.png` | 18 (3x6) | 48x48 | ★★★ | crops/rice_stages.png |
| 75 | Cây trồng lớn lên B | `crops/growth_b.png` | 18 (3x6) | 48x48 | ★★ | crops/growth_a.png |
| 76 | Cây ăn quả lớn lên | `crops/fruit_trees.png` | 12 (3x4) | 64x96 | ★ | crops/growth_a.png |

### Đợt 6: Địa hình, cây cối và ngoại cảnh

Ô nền theo mùa, đất canh tác, nước, ruộng, đường, cây lớn, hàng rào, công trình, xe cộ, đồ đường làng. Prompt: [ASSET_PROMPTS_6.md](ASSET_PROMPTS_6.md).

| # | Asset | File | Ô | Cỡ ô cuối | Ưu tiên | Đính kèm |
|---|---|---|---|---|---|---|
| 77 | Ô nền mùa Hè | `tiles/terrain_summer.png` | 8 (4x2) | 48x48 | ★★ | tiles/terrain_tiles.png |
| 78 | Ô nền mùa Thu | `tiles/terrain_autumn.png` | 8 (4x2) | 48x48 | ★★ | tiles/terrain_tiles.png |
| 79 | Ô nền mùa Đông | `tiles/terrain_winter.png` | 8 (4x2) | 48x48 | ★★ | tiles/terrain_tiles.png |
| 80 | Đất canh tác | `tiles/farmland.png` | 8 (4x2) | 48x48 | ★★★ | tiles/terrain_tiles.png |
| 81 | Chướng ngại trên ruộng | `props/field_obstacles.png` | 8 (4x2) | 48x48 | ★★ | props/decor_sheet.png |
| 82 | Bờ nước (16 ô ghép) | `tiles/water_shore.png` | 16 (4x4) | 48x48 | ★★★ | tiles/terrain_tiles.png |
| 83 | Nước chuyển động | `tiles/water_anim.png` | 8 (4x2) | 48x48 | ★ | tiles/terrain_tiles.png |
| 84 | Ruộng lúa | `tiles/paddy.png` | 8 (4x2) | 48x48 | ★★ | tiles/terrain_tiles.png |
| 85 | Đường và lát nền | `tiles/paths.png` | 8 (4x2) | 48x48 | ★★ | tiles/terrain_tiles.png |
| 86 | Nền và tường trong nhà | `tiles/interior.png` | 12 (4x3) | 48x48 | ★★★ | tiles/terrain_tiles.png |
| 87 | Cây lớn mùa Xuân | `props/trees_spring.png` | 8 (4x2) | 128x160 | ★★★ | props/decor_sheet.png |
| 88 | Cây lớn đổi theo mùa | `props/trees_seasons.png` | 12 (3x4) | 128x160 | ★★ | props/trees_spring.png |
| 89 | Bụi cây, hoa, cỏ | `props/flora_small.png` | 12 (4x3) | 48x48 | ★★ | props/decor_sheet.png |
| 90 | Hàng rào và cổng | `props/fences.png` | 8 (4x2) | 64x64 | ★★★ | props/decor_sheet.png |
| 91 | Công trình nông nghiệp lớn | `props/farm_structures.png` | 4 (2x2) | 192x160 | ★★ | props/house.png |
| 92 | Trạm chế biến | `props/crafting_stations.png` | 8 (4x2) | 96x96 | ★★ | props/decor_sheet.png |
| 93 | Xe cộ và thuyền | `props/vehicles.png` | 8 (4x2) | 128x96 | ★ | props/decor_sheet.png |
| 94 | Cầu và bến | `props/bridge_dock.png` | 6 (3x2) | 128x96 | ★★ | props/decor_sheet.png |
| 95 | Công trình công cộng | `props/public_buildings.png` | 6 (3x2) | 256x192 | ★ | props/house.png |
| 96 | Mặt tiền các tiệm khác | `props/shop_facades.png` | 6 (3x2) | 192x160 | ★ | props/grocery_facade.png |
| 97 | Đồ đường làng | `props/street_props.png` | 12 (4x3) | 64x64 | ★★ | props/decor_sheet.png |

### Đợt 7: Nội thất, trang trí và lễ hội

Đồ trong nhà và trong các tiệm, cùng trang trí Tết, Trung thu, theo mùa và hội làng. Prompt: [ASSET_PROMPTS_7.md](ASSET_PROMPTS_7.md).

| # | Asset | File | Ô | Cỡ ô cuối | Ưu tiên | Đính kèm |
|---|---|---|---|---|---|---|
| 98 | Bếp và phòng ăn | `props/interior_kitchen.png` | 8 (4x2) | 96x96 | ★★ | props/interior_sheet.png |
| 99 | Phòng khách và phòng ngủ | `props/interior_living.png` | 12 (4x3) | 96x96 | ★★ | props/interior_sheet.png |
| 100 | Cửa, cửa sổ, đồ treo tường | `props/interior_wall.png` | 12 (4x3) | 64x64 | ★★ | props/interior_sheet.png |
| 101 | Trong Tiệm Tạp Hóa | `props/grocery_interior.png` | 8 (4x2) | 96x96 | ★★ | props/grocery_counter.png |
| 102 | Trong Quán Net và Quán Bida | `props/leisure_interior.png` | 12 (4x3) | 96x96 | ★ | props/net_pc_station.png |
| 103 | Trong quán nước | `props/cafe_interior.png` | 8 (4x2) | 96x96 | ★ | props/interior_sheet.png |
| 104 | Đồ trang trí trong nhà | `props/home_decor.png` | 8 (4x2) | 64x64 | ★ | props/interior_sheet.png |
| 105 | Trang trí Tết | `props/event_tet.png` | 12 (4x3) | 64x64 | ★ | props/decor_sheet.png |
| 106 | Trang trí Trung thu | `props/event_midautumn.png` | 8 (4x2) | 64x64 | ★ | props/decor_sheet.png |
| 107 | Trang trí theo mùa | `props/season_decor.png` | 12 (4x3) | 64x64 | ★ | props/decor_sheet.png |
| 108 | Hội làng | `props/village_festival.png` | 8 (4x2) | 128x128 | ★ | props/decor_sheet.png |

### Đợt 8: Nhân vật và vật nuôi

Hành động và trang phục của Player, dân làng đi lại, chủ tiệm, chân dung hội thoại, vật nuôi, sinh vật nền. Prompt: [ASSET_PROMPTS_8.md](ASSET_PROMPTS_8.md).

| # | Asset | File | Ô | Cỡ ô cuối | Ưu tiên | Đính kèm |
|---|---|---|---|---|---|---|
| 109 | Player: cuốc đất | `characters/player_hoe.png` | 12 (3x4) | 48x64 | ★★★ | characters/player_sheet.png |
| 110 | Player: tưới cây | `characters/player_water.png` | 12 (3x4) | 48x64 | ★★★ | characters/player_sheet.png |
| 111 | Player: gặt bằng liềm | `characters/player_sickle.png` | 12 (3x4) | 48x64 | ★★ | characters/player_sheet.png |
| 112 | Player: chặt cây | `characters/player_axe.png` | 12 (3x4) | 48x64 | ★★ | characters/player_sheet.png |
| 113 | Player: câu cá | `characters/player_fish.png` | 12 (3x4) | 48x64 | ★★ | characters/player_sheet.png |
| 114 | Player: áo mưa và nón lá | `characters/player_rain.png` | 12 (3x4) | 32x48 | ★ | characters/player_sheet.png |
| 115 | Player: áo ấm mùa đông | `characters/player_winter.png` | 12 (3x4) | 32x48 | ★ | characters/player_sheet.png |
| 116 | Player: đồ mùa hè | `characters/player_summer.png` | 12 (3x4) | 32x48 | ★ | characters/player_sheet.png |
| 117 | Player: tư thế đặc biệt | `characters/player_poses.png` | 8 (4x2) | 48x64 | ★★ | characters/player_sheet.png |
| 118 | Dân làng đi lại: bà lão | `characters/npc_grandma.png` | 12 (3x4) | 32x48 | ★★ | characters/player_sheet.png |
| 119 | Dân làng đi lại: ông lão | `characters/npc_grandpa.png` | 12 (3x4) | 32x48 | ★★ | characters/player_sheet.png |
| 120 | Dân làng đi lại: bé trai | `characters/npc_boy.png` | 12 (3x4) | 32x48 | ★ | characters/player_sheet.png |
| 121 | Dân làng đi lại: bé gái | `characters/npc_girl.png` | 12 (3x4) | 32x48 | ★ | characters/player_sheet.png |
| 122 | Chủ các tiệm | `characters/shopkeepers.png` | 12 (2x6) | 32x48 | ★★ | characters/npc_ba_tu.png |
| 123 | Chân dung hội thoại (the young farmer player, Ba Tu the grocery owner, Chu Nam the vegetable seller) | `characters/portraits_a.png` | 12 (4x3) | 128x128 | ★★ | characters/player_sheet.png, npc_ba_tu.png, npc_chu_nam.png |
| 124 | Chân dung hội thoại (the grandmother, the grandfather, the boy) | `characters/portraits_b.png` | 12 (4x3) | 128x128 | ★★ | characters/npc_grandma.png, npc_grandpa.png, npc_boy.png (sau khi có) |
| 125 | Chân dung hội thoại (the girl, the net-cafe owner, the billiard hall owner) | `characters/portraits_c.png` | 12 (4x3) | 128x128 | ★★ | characters/npc_girl.png, shopkeepers.png (sau khi có) |
| 126 | Vật nuôi: gà và gà con | `characters/anim_chicken.png` | 12 (4x3) | 32x32 | ★★★ | props/animals.png |
| 127 | Vật nuôi: lợn | `characters/anim_pig.png` | 12 (4x3) | 48x40 | ★★★ | props/animals.png |
| 128 | Vật nuôi: trâu | `characters/anim_buffalo.png` | 12 (4x3) | 64x48 | ★★ | props/animals.png |
| 129 | Vật nuôi: bò | `characters/anim_cow.png` | 12 (4x3) | 64x48 | ★★ | props/animals.png |
| 130 | Vật nuôi: chó | `characters/anim_dog.png` | 12 (4x3) | 40x32 | ★★ | props/animals.png |
| 131 | Vật nuôi: mèo | `characters/anim_cat.png` | 12 (4x3) | 32x32 | ★★ | props/animals.png |
| 132 | Vật nuôi: vịt | `characters/anim_duck.png` | 12 (4x3) | 32x32 | ★★ | props/animals.png |
| 133 | Sinh vật nền | `props/wildlife.png` | 12 (4x3) | 32x32 | ★ | props/animals.png |

### Đợt 9: Hiệu ứng và mini-game

Hiệu ứng hạt/thời tiết/hoạt ảnh môi trường và bộ ảnh cho các mini-game. Prompt: [ASSET_PROMPTS_9.md](ASSET_PROMPTS_9.md).

| # | Asset | File | Ô | Cỡ ô cuối | Ưu tiên | Đính kèm |
|---|---|---|---|---|---|---|
| 134 | Hiệu ứng hành động | `fx/fx_actions.png` | 24 (4x6) | 32x32 | ★★ | icons/item_icons.png |
| 135 | Thời tiết và hạt bay | `fx/fx_weather.png` | 16 (4x4) | 32x32 | ★★ | icons/item_icons.png |
| 136 | Hoạt ảnh môi trường | `fx/fx_environment.png` | 20 (4x5) | 48x48 | ★ | icons/item_icons.png |
| 137 | Mini-game Quán Net: bộ ảnh | `minigames/aim_kit.png` | 12 (4x3) | 64x64 | ★★ | minigames/aim_target.png |
| 138 | Mini-game Bida: bàn nhìn từ trên | `minigames/billiards_table_top.png` | 1 (1x1) | 320x192 | ★★ | props/billiards_table.png |
| 139 | Mini-game Bida: phụ kiện | `minigames/billiards_kit.png` | 8 (4x2) | 64x64 | ★★ | minigames/billiard_balls.png |
| 140 | Mini-game Câu cá: bộ ảnh | `minigames/fishing_kit.png` | 12 (4x3) | 64x64 | ★ | icons/fish.png (sau khi có) |
| 141 | Ô ăn quan: bàn cờ | `minigames/o_an_quan_board.png` | 1 (1x1) | 512x256 | ★ | props/decor_sheet.png |
| 142 | Ô ăn quan: quân cờ | `minigames/o_an_quan_pieces.png` | 4 (4x1) | 64x64 | ★ | minigames/o_an_quan_board.png (sau khi có) |

## 6. Quy ước kích thước

- Ô nền: **48x48**. Người cao khoảng 48, nhân vật nhỏ rộng 32.
- Icon vật phẩm: **64x64** (hiển thị thu nhỏ); icon HUD/tab/thời tiết: **32x32**.
- Cỡ ô ghi trong bảng là cỡ *dự kiến*; sau khi có ảnh tôi đo mật độ pixel thực tế và chốt cỡ (như các đợt trước, ảnh AI hay lệch 20-50%).
- Tên file ở đây là đường dẫn trong `assets/art/`.
