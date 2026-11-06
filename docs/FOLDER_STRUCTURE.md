# Cấu trúc thư mục — Hương Quê (Rustic Roots)

Nguyên tắc: **gom theo tính năng (feature)**, không gom theo loại file. Scene (`.tscn`)
và script (`.gd`) của cùng một thực thể nằm chung một thư mục. Dữ liệu thuần (`.tres`)
tách riêng trong `data/` để sửa số liệu mà không đụng code.

```
res://
├─ project.godot
├─ main.tscn / main.gd         # [có] Scene gốc: World + Player + HUD + ShopUI, nhờ SceneManager nạp map đầu
├─ core/                       # Hạ tầng dùng chung, không phụ thuộc gameplay
│  ├─ terrain_tiles.gd         # [có] Sheet nền đất 48x48 (TerrainTiles): enum ô, tileset, vùng nguồn
│  ├─ autoload/
│  │  ├─ event_bus.gd          # [có] Kênh signal toàn cục
│  │  ├─ time_manager.gd       # [có] Đồng hồ, lịch, mùa
│  │  ├─ item_database.gd      # [có] Tra ItemData theo id (tự quét data/items, data/crops)
│  │  ├─ economy_manager.gd    # [có] Tiền của người chơi
│  │  ├─ world_state_manager.gd   # [có] Nhớ trạng thái node "world_persistent" của từng map
│  │  ├─ scene_manager.gd         # [có] Chuyển map (fade), giữ Player, đặt tại SpawnPoint
│  │  └─ save_manager.gd          # [có] Lưu/nạp JSON (user://saves), tự lưu khi sang ngày
│  └─ resources/               # Lớp Resource (định nghĩa dữ liệu)
│     ├─ item_data.gd          # [có]
│     ├─ crop_item_data.gd     # [có]
│     ├─ inventory_slot.gd     # [có] Một ô kho (item + số lượng), dữ liệu runtime
│     ├─ vendor_data.gd        # [có] Giờ mở cửa, hàng cố định/ngẫu nhiên, hệ số giá
│     └─ vendor_stock_entry.gd # [có] Một dòng hàng runtime (item + số lượng)
│
├─ components/                 # Node độc lập gắn vào Entity (Composition over Inheritance)
│  ├─ inventory/               # [có] inventory_component.gd
│  ├─ farming/                 # [có] farm_field (logic), farm_view (vẽ), farm_tool_controller, farm_plot
│  ├─ vendor/                  # [có] vendor_component.gd (kho hàng ngày, mua/bán)
│  ├─ interactable/            # [có] interactable_component.gd (Area2D, signal interacted)
│  └─ transition/              # [có] scene_exit.gd (lối ra), spawn_point.gd (điểm xuất hiện)
│
├─ entities/                   # Thực thể trong thế giới = scene + script riêng
│  ├─ player/                  # [có] player.tscn + player.gd (di chuyển, kho đồ, nhắm đối tượng)
│  ├─ arcade/                  # [có] arcade_station.tscn (trạm chơi mini-game, bấm E)
│  ├─ npc/
│  └─ vendor/                  # [có] vendor_npc.tscn (dùng chung cho tạp hóa và thương lái)
│
├─ maps/                       # Mỗi map là một scene độc lập
│  ├─ map_base.gd              # [có] Lớp nền map: nền, tường, add_spawn(), add_exit()
│  ├─ home/                    # [có] Vườn (FarmField), giường, lối ra Tạp hóa/Chợ
│  ├─ entertainment/           # [có] Khu Giải trí: trạm Quán Net và Quán Bida
│  ├─ grocery_store/           # [có] Mở 6h–21h, hàng cố định
│  └─ morning_market/          # [có] Mở 5h–11h, hàng RNG theo ngày
│
├─ minigames/                  # Scene mini-game, trả kết quả qua EventBus.minigame_finished
│  ├─ minigame_base.gd         # [có] Lớp nền: khung UI, phí, finish() trả kết quả
│  ├─ minigame_host.gd         # [có] Thu phí, dừng đồng hồ, áp kết quả (tiền, thời gian)
│  ├─ net_cafe/                # [có] aim_game (bắn mục tiêu)
│  └─ billiards/               # [có] billiards_game (canh lực)
│
├─ ui/                         # Giao diện, chỉ nghe EventBus
│  ├─ hud/                     # [có] hud.gd (giờ, tiền, gợi ý tương tác, thông báo nhanh); thanh nhanh [sau]
│  ├─ menu/                    # [có] start_menu.gd (Ván mới / Tiếp tục / Thoát)
│  ├─ pause/                   # [có] pause_menu.gd (Esc: Tiếp tục / Lưu / Tải)
│  ├─ shop/                    # [có] shop_ui.tscn dùng chung cho mọi Vendor
│  └─ inventory/               # [có] inventory_ui, inventory_slot_ui
│
├─ data/                       # File .tres: toàn bộ số liệu game (không hardcode trong code)
│  ├─ items/                   # lua.tres, ...
│  ├─ crops/                   # hat_giong_lua.tres, ...
│  └─ vendors/                 # tap_hoa.tres, thuong_lai_rau.tres, ...
│
├─ assets/
│  ├─ art/                     # [có] tiles/terrain_tiles.png (nền đất, đã nối vào game), palette.hex, source/ (ảnh gốc)
│  ├─ audio/
│  └─ fonts/
│
├─ tests/                      # [có] test_base.gd + 11 bài test + run_all.sh (xem README)
├─ tools/                      # [có] slice_sheet.gd (cắt/thu nhỏ/quy về bảng màu ảnh AI)
└─ docs/                       # Tài liệu đồ án, screenshots/
```

## Quy tắc phụ thuộc

| Từ | Được phép dùng | Không được |
|---|---|---|
| `ui/` | `EventBus`, `core/resources` | Gọi trực tiếp script của `entities/` |
| `entities/`, `maps/` | `components/`, `EventBus`, `core/resources` | Gọi trực tiếp script trong `ui/` |
| `components/` | `EventBus`, `core/resources` | Biết entity chủ sở hữu cụ thể |
| `core/` | Chỉ chính nó | Phụ thuộc `ui/`, `entities/`, `maps/` |

## Quy ước đặt tên

- File và thư mục: `snake_case`. Scene và script cùng tên (`player.tscn` + `player.gd`).
- Class (`class_name`): `PascalCase`. **Autoload không dùng `class_name`.**
- Signal: thì quá khứ (`item_picked`) hoặc `..._requested`.
- Id dữ liệu: `StringName`, `snake_case`, khớp tên file (`hat_giong_lua`).
