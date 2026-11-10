# Cân bằng kinh tế

Mọi con số (giá, sản lượng, thưởng mini-game) nằm trong dữ liệu `.tres` và vài `@export` của mini-game, không nằm trong code logic. Công cụ và test dưới đây giữ cho chúng cân bằng khi chỉnh.

| Việc | Lệnh / file |
|---|---|
| Xem báo cáo lãi của mọi cây, vật nuôi, mini-game | `godot --headless --path . -s tools/economy_report.gd` |
| Sinh lại dữ liệu cây từ bảng giá | `bash tools/make_crop_data.sh` (sửa bảng `TABLE` ở đầu file) |
| Kiểm tra các ngưỡng cân bằng | `tests/test_economy.gd` (ngưỡng ở `TARGETS` trong `tools/economy_report.gd`) |

## Quy ước

- Người chơi **mua hạt giống ở Tạp Hóa** (giá = `base_price` x 1,0) và **bán nông sản ở Chợ** (giá = `base_price` x 0,6, chỉ nhận nhóm Cây trồng và Thực phẩm, mở 5h-11h). Chợ bán cho người chơi với hệ số 1,2.
- Vì giá thu mua (0,6) luôn thấp hơn giá bán ra (1,0 và 1,2), không có cách kiếm lời bằng mua đi bán lại.
- **Lãi/ô/ngày** (PPD) = (số nông sản x giá bán - giá hạt) / số ngày lớn. Đây là thước đo chính để so sánh các loại cây. Vườn gốc có 40 ô (8x5), mở rộng tối đa 64 ô.
- Vốn khởi đầu: 100 đ, 10 hạt lúa, 4 trứng gà.

## Mục tiêu

| Chỉ số | Mục tiêu |
|---|---|
| Lãi/ô/ngày của mỗi loại cây | 7 - 14 đ |
| Loại lãi nhất / loại lãi ít nhất | tối đa 1,8 lần |
| Gà giống hoàn vốn | tối đa 8 ngày |
| Một lứa lợn (đã trừ giống và thức ăn) | lãi tối thiểu 40 đ |
| Mini-game, chơi hoàn hảo | 8 - 45 đ/giờ trong game |
| Mini-game cả ngày (16 giờ) | thấp hơn một vườn đã mở rộng hết (64 ô) |

## Giá hiện tại

### Cây trồng (hạt mua ở Tạp Hóa, bán ra Chợ x0,6)

| Cây | Mùa gieo | Ngày | SL | Giá hạt | Giá nông sản (base) | Bán ra | Lãi/ô/ngày |
|---|---|---|---|---|---|---|---|
| Rau muống | Xuân, Hạ, Thu | 3 | 4 | 8 | 14 | 8 | 8,0 |
| Lúa | Xuân, Hạ | 4 | 3 | 10 | 24 | 14 | 8,0 |
| Đậu | Xuân, Thu | 4 | 4 | 15 | 22 | 13 | 9,3 |
| Dưa leo | Hạ | 4 | 3 | 18 | 34 | 20 | 10,5 |
| Cà chua | Xuân, Hạ | 5 | 3 | 20 | 40 | 24 | 10,4 |
| Cà rốt | Xuân, Thu, Đông | 5 | 3 | 15 | 37 | 22 | 10,2 |
| Ớt | Hạ | 5 | 5 | 18 | 25 | 15 | 11,4 |
| Bắp cải | Thu, Đông | 6 | 2 | 25 | 77 | 46 | 11,2 |
| Ngô | Hạ, Thu | 6 | 3 | 22 | 50 | 30 | 11,3 |
| Khoai lang | Thu, Đông | 6 | 3 | 20 | 49 | 29 | 11,2 |
| Bí đỏ | Thu | 7 | 2 | 40 | 104 | 62 | 12,0 |
| Dưa hấu | Hạ | 7 | 2 | 50 | 119 | 71 | 13,1 |

Cây chậm lớn hoặc đắt hạt lãi nhỉnh hơn một chút để bù vốn và thời gian, nhưng không loại nào áp đảo; cây rẻ, nhanh (rau muống, lúa) là lựa chọn an toàn khi mới chơi.

### Vật nuôi

| | Giống | Thức ăn | Sản phẩm | Lãi |
|---|---|---|---|---|
| Gà | 40 đ | cám gà 12 đ/ngày (mua ở Tạp Hóa) | 3 trứng/ngày, trứng bán 7 đ | 9 đ/ngày, hoàn vốn 4,4 ngày |
| Lợn | 120 đ | lúa x 5 ngày (tính 14 đ/lúa theo giá bán lại) | 4 thịt lợn, bán 65 đ | 70 đ mỗi lứa (14 đ/ngày) |

Gà ăn cám gà (món có bán ở Tạp Hóa) nên mua đồ ở tiệm là một khoản chi thật; lợn ăn lúa tự trồng, nối chăn nuôi với trồng trọt.

### Mini-game (lãi ròng sau phí, mỗi giờ trong game)

| | Phí | Thời gian | Thưởng tối đa | Hoàn hảo | Trung bình |
|---|---|---|---|---|---|
| Quán Net | 5 đ | 60 phút | 30 đ (2 đ/lần trúng) | 25 đ/giờ | ~25 đ/giờ (chạm trần) |
| Quán Bida | 15 đ | 45 phút | 45 đ (9 đ/bi, 5 cú) | 40 đ/giờ | ~4 đ/giờ (vào 2 bi) |

Quán Net dễ kiếm đều nhưng có trần thấp; Quán Bida thưởng cao cho người canh lực giỏi, người chơi trung bình chỉ hòa vốn.

## Hạn chế

- Chưa có khoản chi lớn nào ngoài hạt giống, cám gà và con giống, nên khi vườn đầy tiền sẽ dư. Hướng phát triển: nâng cấp nhà, mở rộng vườn, dụng cụ, trang trí.
- Chưa mô phỏng người chơi thật; các con số mới được kiểm bằng mô hình lãi/ô/ngày và so sánh tương đối, cần chơi thử để chỉnh tiếp.

## Nâng cấp (chỗ tiêu tiền)

Nâng cấp mua qua ông Bảy ở sân nhà (bấm `E`, chọn **Nhờ làm giúp**). Dữ liệu nằm ở `data/upgrades/*.tres` (`UpgradeData`), mua bán do `UpgradeManager`, hiệu lực do từng hệ thống tự áp qua `EventBus.upgrade_purchased`.

| Nâng cấp | Cấp 1 | Cấp 2 | Cấp 3 | Hiệu lực |
|---|---|---|---|---|
| Mở rộng vườn | 200 đ | 450 đ | 900 đ | 5 -> 6 -> 7 -> 8 hàng (thêm hàng phía trên, +8 ô mỗi cấp; vườn gốc 8x5 = 40 ô) |
| Dụng cụ tốt hơn | 400 đ | 900 đ | 1800 đ | 1 -> 2 -> 3 -> 6 ô mỗi lần cuốc/gieo/thu hoạch |
| Mở rộng chuồng gà | 150 đ | 300 đ | | 4 -> 6 -> 8 gà |
| Mở rộng chuồng lợn | 300 đ | 550 đ | | 4 -> 6 -> 8 lợn |
| Túi đồ lớn hơn | 150 đ | 400 đ | | 16 -> 24 -> 32 ô |

Tổng 6500 đ, tương đương khoảng 15 ngày thu nhập của vườn gốc 40 ô. Mỗi cấp tăng thu nhập (vườn, chuồng) đều hoàn vốn trong tối đa 20 ngày theo lãi tối thiểu (`tests/test_upgrades.gd` kiểm tra), nên đáng mua nhưng không phải mua ngay.

## Mở rộng sau đợt cân bằng đầu

Các phần dưới đây được thêm sau và có test riêng giữ cân bằng; `tools/economy_report.gd` chưa in các mục này.

| Mục | Số liệu | Test |
|---|---|---|
| Vịt | giống 60 đ; ăn 1 rau muống/ngày; 2 trứng vịt/ngày (trứng base 17, cô Ba mua 11 đ) -> lãi khoảng 12 đ/ngày, hoàn vốn 5 ngày | `test_more_animals` |
| Trâu | nghé 350 đ; ăn 1 rau muống/ngày; 1 phân bón/ngày; mỗi phân bón cho thêm 1 nông sản khi thu hoạch (14-71 đ tuỳ cây) | `test_more_animals` |
| Sạp cô Ba | chỉ thu mua thực phẩm, x0,7 (chú Năm x0,6) | `test_market_stalls` |
| Hàng xén cô Út | 3 loại hạt giống mỗi ngày, x0,9 giá Tạp Hóa; lãi/ô/ngày cao nhất khi mua ở đây vẫn <= 14 đ | `test_market_stalls` |
| Món ăn | 10 công thức; giá món (bán cô Ba) bằng 1,10-1,35 lần giá bán nguyên liệu sống; mỗi món mất 15-60 phút | `test_cooking` |
| Giặt đồ | 1 xà phòng (15 đ) + 60 phút cho 3 ngày gấp đôi điểm thân thiết | `test_laundry` |
| Ô ăn quan | phí 10 đ, 60 phút, thắng 30 đ (lãi 20 đ/giờ), hoà hoàn phí | `test_o_an_quan` |

Quy tắc chung vẫn giữ: không có cặp "mua ở sạp này, bán ở sạp kia" hay "mua nguyên liệu, nấu rồi bán" nào có lời, vì giá thu mua cao nhất (x0,7, món ăn thêm tối đa 35%) luôn thấp hơn giá bán ra thấp nhất (x0,9 chỉ áp cho hạt giống, thứ không sạp nào thu mua).

## Thể lực và tưới cây (giới hạn công việc mỗi ngày)

- Thể lực tối đa 100 mỗi ngày (ngủ giường hồi đầy). Mỗi ô: cuốc 3; gieo, tưới, thu hoạch, bón phân 1.
- Cây chỉ lớn vào ngày được tưới, nên một vườn 40 ô đang trồng tốn 40 sức mỗi ngày chỉ để tưới; ngày vừa thu hoạch vừa gieo lại cả vườn tốn khoảng 120 sức, tức phải ăn thêm.
- Ăn hồi sức: món nấu hồi bằng 1/3 giá món (cơm trắng 17, bánh chưng 97), đồ sống hồi 5-15. Ăn một món nghĩa là bỏ khoản tiền bán món đó, nên thể lực có giá: khoảng 2 đ cho mỗi điểm sức khi ăn món nấu.
- Các bảng lãi/ô/ngày ở trên giả định ô nào cũng được tưới đủ ngày; chưa có mô hình tính lãi sau khi trừ chi phí thể lực. Phần này cần chơi thử để chỉnh (mức tốn sức nằm ở `StaminaManager.COSTS`, năng lượng món ăn ở `tools/make_food_data.sh`).
