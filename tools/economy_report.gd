extends SceneTree
## Báo cáo cân bằng kinh tế: lãi từng loại cây, vật nuôi và mini-game theo giá hiện tại trong dữ liệu.
## Chạy:  godot --headless --path . -s tools/economy_report.gd
##
## Quy ước tính (giống game):
## - Người chơi mua hạt giống ở Tạp Hóa (giá = base_price x hệ số mua) và bán nông sản ở Chợ (giá = base_price x hệ số thu mua, hiện 0,6).
## - "Lãi/ô/ngày" (PPD) = (số nông sản x giá bán - giá hạt) / số ngày lớn: thước đo chính để so sánh các loại cây.
## - Vật nuôi tính theo từng con; thức ăn tính theo giá MUA ở Tạp Hóa.
## - Mini-game tính lãi ròng mỗi giờ trong game (sau phí vào cửa) nếu chơi hoàn hảo / trung bình.
##
## Các ngưỡng mục tiêu dùng chung với tests/test_economy.gd (khai báo ở [constant TARGETS]).

## Ngưỡng mục tiêu của cân bằng (test_economy.gd kiểm tra đúng các số này).
const TARGETS: Dictionary = {
	"min_crop_ppd": 7.0,  # mỗi loại cây tối thiểu lãi/ô/ngày
	"max_crop_ppd": 14.0,  # và tối đa (không có loại "ăn đứt")
	"max_ppd_ratio": 1.8,  # loại lãi nhất / loại ít nhất
	"max_hen_payback_days": 8.0,  # gà giống hoàn vốn trong chừng này ngày
	"min_pig_cycle_profit": 40.0,  # một lứa lợn tối thiểu lãi
	"max_pig_payback_cycles": 3.0,
	"max_minigame_hourly": 45.0,  # lãi ròng tối đa/giờ khi chơi hoàn hảo
	"min_minigame_hourly": 8.0,  # lãi ròng tối thiểu/giờ khi chơi hoàn hảo (đáng chơi)
}

const CROP_IDS: Array[String] = [
	"hat_giong_rau_muong", "hat_giong_lua", "hat_giong_dau", "hat_giong_dua_leo", "hat_giong_ca_chua", "hat_giong_ca_rot",
	"hat_giong_ot", "hat_giong_bap_cai", "hat_giong_ngo", "hat_giong_khoai_lang", "hat_giong_bi_do", "hat_giong_dua_hau",
]


func _initialize() -> void:
	# Chờ một khung hình cho autoload (ItemDatabase, EventBus...) sẵn sàng; xem lưu ý trong tests/test_base.gd.
	await process_frame
	var db: Node = root.get_node("ItemDatabase")
	var grocery: VendorData = load("res://data/vendors/tap_hoa.tres")
	var market: VendorData = load("res://data/vendors/thuong_lai_rau.tres")

	print("=== CÂY TRỒNG (bán ở Chợ x%.2f, mua hạt ở Tạp Hóa x%.2f) ===" % [market.sell_multiplier, grocery.buy_multiplier])
	print("%-22s %4s %4s %5s %6s %6s %7s %7s" % ["hạt giống", "ngày", "sl", "hạt", "giá bán", "doanh", "lãi/hạt", "lãi/ô/ngày"])
	var min_ppd: float = INF
	var max_ppd: float = 0.0
	for id: String in CROP_IDS:
		var seed_item: CropItemData = db.get_item(StringName(id)) as CropItemData
		var product: ItemData = db.get_item(seed_item.harvest_item_id)
		var seed_cost: int = grocery.get_buy_price(seed_item)
		var sell: int = market.get_sell_price(product)
		var revenue: int = sell * seed_item.harvest_amount
		var profit: int = revenue - seed_cost
		var ppd: float = float(profit) / seed_item.grow_days
		min_ppd = minf(min_ppd, ppd)
		max_ppd = maxf(max_ppd, ppd)
		print("%-22s %4d %4d %5d %6d %6d %7d %9.1f" % [id, seed_item.grow_days, seed_item.harvest_amount, seed_cost, sell, revenue, profit, ppd])
	print("-> lãi/ô/ngày thấp nhất %.1f, cao nhất %.1f, tỉ lệ %.2f (mục tiêu %.0f-%.0f, tỉ lệ <= %.1f)" % [min_ppd, max_ppd, max_ppd / maxf(min_ppd, 0.01), TARGETS["min_crop_ppd"], TARGETS["max_crop_ppd"], TARGETS["max_ppd_ratio"]])

	print("\n=== VẬT NUÔI (mỗi con) ===")
	for animal_path: String in ["res://data/animals/ga.tres", "res://data/animals/lon.tres"]:
		var animal: AnimalData = load(animal_path)
		var baby: ItemData = db.get_item(animal.baby_item_id)
		var feed: ItemData = db.get_item(animal.feed_item_id)
		var product: ItemData = db.get_item(animal.product_item_id)
		var baby_cost: int = grocery.get_buy_price(baby)
		var feed_cost: int = grocery.get_buy_price(feed) if grocery.fixed_items.has(feed) else market.get_sell_price(feed)  # không bán ở Tạp Hóa (vd. lúa tự trồng): tính theo giá bán lại
		var sell: int = market.get_sell_price(product)
		var revenue: int = sell * animal.product_amount
		var cycle_cost: int = feed_cost * animal.fed_days_per_product
		var cycle_profit: int = revenue - cycle_cost
		var per_day: float = float(cycle_profit) / animal.fed_days_per_product
		if animal.keeps_producing:
			print("%s: giống %d đ, thức ăn %s %d đ/ngày; mỗi ngày %d x %d đ = %d đ -> lãi %.1f đ/ngày, hoàn vốn %.1f ngày" % [animal.display_name, baby_cost, feed.display_name, feed_cost, animal.product_amount, sell, revenue, per_day, float(baby_cost) / maxf(per_day, 0.01)])
		else:
			print("%s: giống %d đ, thức ăn %s %d đ x %d ngày; xuất chuồng %d x %d đ = %d đ -> lãi mỗi lứa %d đ (%.1f đ/ngày), hoàn vốn %.1f lứa" % [animal.display_name, baby_cost, feed.display_name, feed_cost, animal.fed_days_per_product, animal.product_amount, sell, revenue, cycle_profit - baby_cost, per_day - float(baby_cost) / animal.fed_days_per_product, float(baby_cost) / maxf(float(cycle_profit), 0.01)])

	print("\n=== MINI-GAME (lãi ròng mỗi giờ trong game) ===")
	var aim = load("res://minigames/net_cafe/aim_game.gd").new()
	var aim_hits_perfect: int = int(aim.round_seconds / aim.spawn_interval)
	var aim_best: int = mini(aim_hits_perfect * aim.pay_per_hit, aim.max_payout)
	var aim_avg: int = mini(int(aim_hits_perfect * 0.6) * aim.pay_per_hit, aim.max_payout)
	print("Quán Net: phí %d đ, %d phút, tối đa %d đ -> hoàn hảo %.1f đ/giờ, trung bình (60%% trúng) %.1f đ/giờ" % [aim.entry_fee, aim.minutes_cost, aim.max_payout, _hourly(aim_best, aim.entry_fee, aim.minutes_cost), _hourly(aim_avg, aim.entry_fee, aim.minutes_cost)])
	var pool = load("res://minigames/billiards/billiards_game.gd").new()
	var pool_best: int = pool.shots_per_round * pool.pay_per_ball
	var pool_avg: int = int(pool.shots_per_round * 0.5) * pool.pay_per_ball
	print("Quán Bida: phí %d đ, %d phút, %d cú x %d đ -> hoàn hảo %.1f đ/giờ, trung bình (một nửa vào lỗ) %.1f đ/giờ" % [pool.entry_fee, pool.minutes_cost, pool.shots_per_round, pool.pay_per_ball, _hourly(pool_best, pool.entry_fee, pool.minutes_cost), _hourly(pool_avg, pool.entry_fee, pool.minutes_cost)])
	aim.free()
	pool.free()
	print("\nGhi chú: vườn có 70 ô; ban đầu có 100 đ và 10 hạt lúa. Mục tiêu và ngưỡng ở TARGETS (đầu file).")
	quit()


func _hourly(payout: int, fee: int, minutes: int) -> float:
	return float(payout - fee) * 60.0 / maxf(minutes, 1)
