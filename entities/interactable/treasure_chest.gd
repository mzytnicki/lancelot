extends StaticBody2D
## A treasure chest that persists opened state through GameManager flags.

signal opened

@export var scene_key: String = "crystal_cavern"
@export var chest_id: String = ""
@export var item: ItemData
@export var item_count: int = 1

var is_opened: bool = false
var _player_in_range: bool = false

@onready var _sprite: Sprite2D = $Sprite
@onready var _prompt: Label = $InteractionPrompt
@onready var _zone: Area2D = $InteractionZone


func _ready() -> void:
	_zone.body_entered.connect(_on_body_entered)
	_zone.body_exited.connect(_on_body_exited)
	_prompt.visible = false
	if chest_id.is_empty():
		push_warning("TreasureChest needs a stable chest_id for save/load.")
	is_opened = GameManager.has_flag(_world_flag(chest_id, "opened"))
	_refresh_sprite()


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range or is_opened:
		return
	if event.is_action_pressed("interact"):
		_open()
		get_viewport().set_input_as_handled()


func _open() -> void:
	if is_opened:
		return

	is_opened = true
	GameManager.set_flag(_world_flag(chest_id, "opened"))
	if item:
		InventoryManager.add_item(item, item_count)
		print("Found: " + item.display_name + " x" + str(item_count))
	_refresh_sprite()
	opened.emit()


func _refresh_sprite() -> void:
	_prompt.visible = _player_in_range and not is_opened
	if is_opened:
		# Swap to your open-chest texture or frame here.
		_sprite.frame = 1


func _world_flag(object_id: String, state: String) -> String:
	return GameManager.make_world_flag(scene_key, object_id, state)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		_refresh_sprite()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_refresh_sprite()
