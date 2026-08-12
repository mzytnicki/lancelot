extends Node
## Manages the player's inventory. Autoload, accessible as InventoryManager.

signal item_added(item: ItemData, new_count: int)
signal item_removed(item: ItemData, new_count: int)
signal inventory_changed
signal gold_changed(new_amount: int)

var gold: int = 100  # Starting gold
var _items: Array[Dictionary] = []  # [{item: ItemData, count: int}]


func _ready() -> void:
	# Starting inventory for testing
	var potion: ItemData = load("res://data/items/potion.tres")
	if potion:
		add_item(potion, 3)


func add_item(item: ItemData, amount: int = 1) -> void:
	if amount <= 0:
		return

	for entry in _items:
		if entry.item.id == item.id:
			entry.count += amount
			item_added.emit(item, entry.count)
			inventory_changed.emit()
			return

	_items.append({item = item, count = amount})
	item_added.emit(item, amount)
	inventory_changed.emit()


func remove_item(item: ItemData, amount: int = 1) -> bool:
	if amount <= 0:
		return false

	for i in _items.size():
		if _items[i].item.id == item.id:
			var entry: Dictionary = _items[i]
			if entry.count < amount:
				return false

			entry.count -= amount
			var remaining: int = entry.count
			if remaining <= 0:
				_items.remove_at(i)
				remaining = 0
			else:
				_items[i] = entry
			item_removed.emit(item, remaining)
			inventory_changed.emit()
			return true
	return false


func has_item(item_id: String, amount: int = 1) -> bool:
	for entry in _items:
		if entry.item.id == item_id and entry.count >= amount:
			return true
	return false


func get_item_count(item_id: String) -> int:
	for entry in _items:
		if entry.item.id == item_id:
			return entry.count
	return 0


func get_all_items() -> Array[Dictionary]:
	return _items.duplicate(true)


func get_consumables() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry in _items:
		if entry.item.item_type == ItemData.ItemType.CONSUMABLE:
			result.append(entry.duplicate(true))
	return result


func use_item(item: ItemData) -> bool:
	if not item or item.item_type != ItemData.ItemType.CONSUMABLE:
		return false
	if item.hp_restore <= 0 and item.mp_restore <= 0:
		return false
	return remove_item(item)


func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)


func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		gold_changed.emit(gold)
		return true
	return false
