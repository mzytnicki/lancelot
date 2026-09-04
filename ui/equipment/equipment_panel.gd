extends PanelContainer
## Equipment management for a party member.

signal equipment_changed

var _character: CharacterData

@onready var _name_label: Label = $VBox/NameLabel
@onready var _stats_label: RichTextLabel = $VBox/StatsLabel
@onready var _weapon_button: Button = $VBox/Slots/WeaponButton
@onready var _armor_button: Button = $VBox/Slots/ArmorButton
@onready var _accessory_button: Button = $VBox/Slots/AccessoryButton


func show_character(character: CharacterData) -> void:
	_character = character
	_refresh()


func _refresh() -> void:
	_name_label.text = _character.display_name + " (Lv. " + str(_character.level) + ")"
	_stats_label.text = (
		"HP: " + str(_character.max_hp) +
		"  ATK: " + str(_character.get_effective_attack()) +
		"  DEF: " + str(_character.get_effective_defense()) +
		"  SPD: " + str(_character.get_effective_speed())
	)
	_weapon_button.text = "Weapon: " + (_character.equipped_weapon.display_name if _character.equipped_weapon else "(none)")
	_armor_button.text = "Armor: " + (_character.equipped_armor.display_name if _character.equipped_armor else "(none)")
	_accessory_button.text = "Accessory: " + (_character.equipped_accessory.display_name if _character.equipped_accessory else "(none)")


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_weapon_button.pressed.connect(_on_slot_pressed.bind(ItemData.EquipSlot.WEAPON))
	_armor_button.pressed.connect(_on_slot_pressed.bind(ItemData.EquipSlot.ARMOR))
	_accessory_button.pressed.connect(_on_slot_pressed.bind(ItemData.EquipSlot.ACCESSORY))


func open_from_pause() -> void:
	var members := PartyManager.get_members()
	if members.is_empty():
		return
	show_character(members[0])
	visible = true
	get_tree().paused = true
	_weapon_button.grab_focus()


func close() -> void:
	visible = false
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _on_slot_pressed(slot: ItemData.EquipSlot) -> void:
	# Get equipable items for this slot from inventory
	var equipable: Array = []
	for entry in InventoryManager.get_all_items():
		var item: ItemData = entry.item
		if item.item_type == ItemData.ItemType.EQUIPMENT and item.equip_slot == slot:
			equipable.append(item)

	if equipable.is_empty():
		print("No equipment for this slot in inventory.")
		return

	# Simple approach: equip the first matching item.
	# A full UI would show a selection list with stat comparisons.
	var item: ItemData = equipable[0]
	if not InventoryManager.remove_item(item):
		print("Could not equip " + item.display_name + ": item is no longer in inventory.")
		return

	var previous: ItemData = _character.equip(item)
	if previous:
		InventoryManager.add_item(previous)

	_refresh()
	equipment_changed.emit()
