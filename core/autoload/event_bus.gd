extends Node
## EventBus (Autoload): kênh tín hiệu toàn cục để các hệ thống giao tiếp mà không biết nhau.
##
## Quy tắc dùng:
## - Bên phát gọi: EventBus.item_picked.emit(item, 1)
## - Bên nghe gọi: EventBus.item_picked.connect(_on_item_picked)
## - Script này CHỈ khai báo signal, không chứa logic hay trạng thái.
## - Đặt tên signal ở thì quá khứ cho sự kiện đã xảy ra (item_picked), và dạng
##   "..._requested" cho yêu cầu cần bên khác xử lý (scene_change_requested).
## - Autoload không dùng class_name (sẽ trùng tên với singleton).

# Các signal ở đây được phát/nghe ở script khác nên Godot báo "unused signal".
@warning_ignore_start("unused_signal")

# --- Thời gian (do TimeManager phát) ------------------------------------------

## Mỗi nhịp đồng hồ. NPC, cửa hàng, ánh sáng nghe tín hiệu này.
signal time_ticked(hour: int, minute: int)
## Khi sang giờ mới (minute = 0). Tiện cho hệ thống chỉ cần theo giờ.
signal hour_changed(hour: int)
## Khi sang ngày mới. [param day] là tổng số ngày kể từ ngày 1. Cây trồng và Chợ nghe.
signal day_changed(day: int)
## Khi sang mùa mới. [param season] là giá trị TimeManager.Season.
signal season_changed(season: int, year: int)
## Người chơi ngủ / hết ngày; hệ thống lưu game và hồi phục chỉ số nghe tín hiệu này.
signal day_ended(day: int)

# --- Vật phẩm & kho đồ ----------------------------------------------------------

## Nhặt được vật phẩm (Player phát; HUD/âm thanh nghe).
signal item_picked(item: ItemData, amount: int)
## Dùng hoặc tiêu hao vật phẩm.
signal item_used(item: ItemData, amount: int)
## Nội dung một kho đồ thay đổi. [param owner_id] phân biệt kho Player/Rương/Kệ hàng.
signal inventory_changed(owner_id: StringName)

# --- Kinh tế & giao thương ------------------------------------------------------

signal money_changed(new_amount: int, delta: int)
## Mở/đóng giao diện cửa hàng. [param vendor] là VendorData (Resource, tạo ở bước sau).
## Yêu cầu mở cửa hàng (VendorNPC phát). [param vendor] là VendorComponent, [param buyer] là InventoryComponent của người mua; ShopUI nghe.
signal shop_open_requested(vendor: Node, buyer: Node)
signal shop_opened(vendor: Resource)
signal shop_closed(vendor: Resource)
## Giao dịch hoàn tất. [param is_buying] = true nếu người chơi mua.
signal transaction_completed(item: ItemData, amount: int, total_price: int, is_buying: bool)

# --- Tương tác & hội thoại ------------------------------------------------------

## Người chơi bắt đầu/kết thúc tương tác với một đối tượng (InteractableComponent phát).
signal interaction_started(interactable: Node)
signal interaction_ended(interactable: Node)
signal dialogue_requested(speaker_id: StringName, dialogue_id: StringName)
## Người chơi muốn nói chuyện với [param npc] (VendorNPC phát; npc có thuộc tính dialogue và vendor);
## [param interactor] là Player. DialogueBox nghe.
signal npc_talk_requested(npc: Node, interactor: Node)
## Hộp thoại mở/đóng ([param speaker_id] là id người nói). Player khoá di chuyển, menu tạm dừng nhường Esc.
signal dialogue_opened(speaker_id: StringName)
signal dialogue_closed(speaker_id: StringName)
## Độ thân thiết với một NPC lên cấp ([param level]: 0-3, xem RelationshipManager).
signal relationship_changed(speaker_id: StringName, level: int)
## Gợi ý tương tác thay đổi (Player phát). Chuỗi rỗng = ẩn gợi ý. HUD nghe.
signal interaction_prompt_changed(text: String)
## Thông báo nhanh cho người chơi (HUD nghe và hiện vài giây).
signal toast_requested(text: String)
## Thông báo có phân loại: [param kind] là &"success" (xanh), &"error" (đỏ) hoặc &"info" (nâu).
signal notice_requested(text: String, kind: StringName)

# --- Nông trại & chăn nuôi ------------------------------------------------------

signal tile_tilled(cell: Vector2i)
signal crop_planted(cell: Vector2i, crop: CropItemData)
signal crop_harvested(cell: Vector2i, crop: CropItemData)
## Cây héo vì sang mùa không hợp (FarmField phát).
signal crop_withered(cell: Vector2i, crop: CropItemData)
signal animal_fed(animal_id: StringName)

# --- Nhân vật ---
## Player đặt chân xuống một bước (khung hình chân chạm đất); AudioManager phát tiếng bước chân.
signal player_stepped

# --- Bản đồ & trạng thái thế giới -----------------------------------------------

## Yêu cầu chuyển map. [param spawn_id] chọn điểm xuất hiện ở map đích.
signal scene_change_requested(scene_path: String, spawn_id: StringName)
signal scene_changed(scene_path: String)
## WorldStateManager phát trước khi rời map để mọi nút lưu trạng thái của mình.
signal world_state_save_requested(scene_path: String)

# --- Mini-game ------------------------------------------------------------------

## Yêu cầu chơi mini-game (trạm chơi phát). [param scene_path] là scene MinigameBase; MinigameHost nghe.
signal minigame_requested(scene_path: String)
signal minigame_started(minigame_id: StringName)
## Trả kết quả về Scene chính, vd: {"money": 50, "stamina": -20}.
signal minigame_finished(minigame_id: StringName, result: Dictionary)

# --- Lưu / tải ------------------------------------------------------------------

signal game_saved
signal game_loaded

@warning_ignore_restore("unused_signal")
