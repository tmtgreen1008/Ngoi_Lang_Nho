# Cấu trúc thư mục — Hương Quê (Rustic Roots)

Nguyên tắc: **gom theo tính năng (feature)**, không gom theo loại file. Scene (`.tscn`)
và script (`.gd`) của cùng một thực thể nằm chung một thư mục. Dữ liệu thuần (`.tres`)
tách riêng trong `data/` để sửa số liệu mà không đụng code.

```
res://
├─ project.godot
├─ core/                       # Hạ tầng dùng chung, không phụ thuộc gameplay
│  ├─ autoload/
│  │  ├─ event_bus.gd          # [có] Kênh signal toàn cục
│  │  ├─ time_manager.gd       # [có] Đồng hồ, lịch, mùa
│  │  ├─ item_database.gd      # [có] Tra ItemData theo id (tự quét data/items, data/crops)
│  │  ├─ world_state_manager.gd   # [sau] Lưu trạng thái từng map khi chuyển scene
│  │  ├─ scene_manager.gd         # [sau] Chuyển map, điểm spawn
│  │  └─ save_manager.gd          # [sau] Ghi/đọc file save
│  └─ resources/               # Lớp Resource (định nghĩa dữ liệu)
│     ├─ item_data.gd          # [có]
│     ├─ crop_item_data.gd     # [có]
│     ├─ inventory_slot.gd     # [có] Một ô kho (item + số lượng), dữ liệu runtime
│     └─ vendor_data.gd        # [sau] Danh sách hàng, giờ mở cửa, hệ số giá
│
├─ components/                 # Node độc lập gắn vào Entity (Composition over Inheritance)
│  ├─ inventory/               # [có] inventory_component.gd
│  └─ interactable/            # InteractableComponent
│
├─ entities/                   # Thực thể trong thế giới = scene + script riêng
│  ├─ player/
│  ├─ npc/
│  └─ vendor/                  # Bà chủ tạp hóa, thương lái ở chợ
│
├─ maps/                       # Mỗi map là một scene độc lập
│  ├─ home/                    # Nhà, vườn (TileMap), chuồng trại
│  ├─ grocery_store/           # Mở 6h–21h, hàng cố định
│  └─ morning_market/          # Mở 5h–11h, hàng RNG theo ngày
│
├─ minigames/                  # Scene mini-game, trả kết quả qua EventBus.minigame_finished
│  ├─ net_cafe/
│  └─ billiards/
│
├─ ui/                         # Giao diện, chỉ nghe EventBus
│  ├─ hud/                     # Đồng hồ, tiền, thanh nhanh
│  ├─ shop/                    # shop_ui.tscn dùng chung cho mọi Vendor
│  └─ inventory/
│
├─ data/                       # File .tres: toàn bộ số liệu game (không hardcode trong code)
│  ├─ items/                   # lua.tres, ...
│  ├─ crops/                   # hat_giong_lua.tres, ...
│  └─ vendors/                 # tap_hoa.tres, thuong_lai_rau.tres, ...
│
├─ assets/
│  ├─ art/
│  ├─ audio/
│  └─ fonts/
│
└─ docs/                       # Tài liệu đồ án
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
