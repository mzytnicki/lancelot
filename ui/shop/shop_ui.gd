extends CanvasLayer
## Shop interface for buying and selling items.

signal shop_closed

var _shop_data: ShopData
var _mode: String = "buy"

@onready var _buy_button: Button = $Panel/Margin/VBox/ModeTabs/BuyButton
@onready var _sell_button: Button = $Panel/Margin/VBox/ModeTabs/SellButton
@onready var _item_list: VBoxContainer = $Panel/Margin/VBox/ItemList
@onready var _gold_label: Label = $Panel/Margin/VBox/GoldLabel


func _ready() -> void:
	# Must process while paused so the shop can receive input
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_buy_button.pressed.connect(_set_mode.bind("buy"))
	_sell_button.pressed.connect(_set_mode.bind("sell"))


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close_shop()
		get_viewport().set_input_as_handled()


func open_shop(shop_data: ShopData) -> void:
	_shop_data = shop_data
	_mode = "buy"
	visible = true
	get_tree().paused = true
	_refresh()


func close_shop() -> void:
	visible = false
	get_tree().paused = false
	shop_closed.emit()


func _refresh() -> void:
	for child in _item_list.get_children():
		child.queue_free()

	await get_tree().process_frame

	_gold_label.text = "Gold: " + str(InventoryManager.gold)
	_buy_button.disabled = _mode == "buy"
	_sell_button.disabled = _mode == "sell"

	if _mode == "buy":
		_refresh_buy_list()
	else:
		_refresh_sell_list()

	if _item_list.get_child_count() > 0:
		await get_tree().process_frame
		_item_list.get_child(0).grab_focus()


func _set_mode(mode: String) -> void:
	_mode = mode
	_refresh()


func _refresh_buy_list() -> void:
	for item in _shop_data.items_for_sale:
		var button := Button.new()
		button.text = item.display_name + " - " + str(item.buy_price) + "g"
		if InventoryManager.gold < item.buy_price:
			button.disabled = true
		button.pressed.connect(_buy_item.bind(item))
		_item_list.add_child(button)


func _refresh_sell_list() -> void:
	for entry in InventoryManager.get_all_items():
		var item: ItemData = entry.item
		if item.sell_price <= 0:
			continue
		var button := Button.new()
		button.text = item.display_name + " x" + str(entry.count) + " - " + str(item.sell_price) + "g"
		button.pressed.connect(_sell_item.bind(item))
		_item_list.add_child(button)


func _buy_item(item: ItemData) -> void:
	if InventoryManager.spend_gold(item.buy_price):
		InventoryManager.add_item(item)
		print("Bought " + item.display_name + "!")
		_refresh()


func _sell_item(item: ItemData) -> void:
	if InventoryManager.remove_item(item):
		InventoryManager.add_gold(item.sell_price)
		print("Sold " + item.display_name + "!")
		_refresh()
