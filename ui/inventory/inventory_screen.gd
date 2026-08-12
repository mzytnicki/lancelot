extends CanvasLayer
## The inventory screen. Opens/closes with the menu key.

const ItemSlotScene := preload("res://ui/inventory/item_slot.tscn")

@onready var _panel: PanelContainer = $PanelContainer
@onready var _item_grid: GridContainer = $PanelContainer/MarginContainer/VBoxContainer/ItemGrid
@onready var _gold_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Header/GoldLabel
@onready var _description_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/DescriptionLabel

var _is_open: bool = false


func _ready() -> void:
	_panel.visible = false
	InventoryManager.inventory_changed.connect(_refresh)
	InventoryManager.gold_changed.connect(_on_gold_changed)
	_update_gold_display()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _is_open:
		close()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("menu") and not _is_open:
		open()
		get_viewport().set_input_as_handled()


func open() -> void:
	_show()


func open_from_pause() -> void:
	_show()


func _show() -> void:
	_is_open = true
	_panel.visible = true
	get_tree().paused = true
	_refresh()


func close() -> void:
	_is_open = false
	_panel.visible = false
	get_tree().paused = false


func _refresh() -> void:
	for child in _item_grid.get_children():
		child.queue_free()

	await get_tree().process_frame

	# Create slots for each item
	var items := InventoryManager.get_all_items()
	for entry in items:
		var slot: PanelContainer = ItemSlotScene.instantiate()
		_item_grid.add_child(slot)
		slot.setup(entry.item, entry.count)
		slot.slot_selected.connect(_on_slot_selected)
		slot.slot_activated.connect(_on_slot_activated)

	# Focus the first slot (deferred so the slot is ready)
	if _item_grid.get_child_count() > 0:
		_item_grid.get_child(0).call_deferred("grab_focus")


func _on_slot_selected(item: ItemData) -> void:
	_description_label.text = item.description


func _on_slot_activated(item: ItemData) -> void:
	if item.item_type == ItemData.ItemType.CONSUMABLE:
		_use_consumable(item)


func _use_consumable(item: ItemData) -> void:
	# Temporary Module 12 behavior: no party target exists yet.
	# Module 21 replaces this with use_item_on_member(item, member).
	if item.hp_restore > 0:
		print("Restored ", item.hp_restore, " HP!")
	if item.mp_restore > 0:
		print("Restored ", item.mp_restore, " MP!")
	InventoryManager.use_item(item)


func _update_gold_display() -> void:
	_gold_label.text = "Gold: " + str(InventoryManager.gold)


func _on_gold_changed(_amount: int) -> void:
	_update_gold_display()
