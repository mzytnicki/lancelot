extends CharacterBody2D
## The player character with state-machine-driven movement and animation.

# GDScript enums define a set of named integer constants.
# This creates State.IDLE = 0, State.WALK = 1, State.INTERACT = 2, State.DISABLED = 3.
# We use them instead of raw integers so the code reads as words, not magic numbers.
enum State { IDLE, WALK, INTERACT, DISABLED, TARGET }

@export var speed: float = 200.0

signal target_reached

var current_state: State = State.IDLE
var facing_direction: Vector2 = Vector2.DOWN  # Vector2(0, 1), positive Y is downward in Godot
var target: Vector2 = Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var camera2d: Camera2D = $Camera2D

# Sprites when gaining/loosing points
@onready var hbox_prouesse:   HBoxContainer = $HBoxProuesse
@onready var hbox_amour:      HBoxContainer = $HBoxAmour
@onready var hbox_courtoisie: HBoxContainer = $HBoxCourtoisie
@onready var label_prouesse:   Label = $HBoxProuesse/Label
@onready var label_amour:      Label = $HBoxAmour/Label
@onready var label_courtoisie: Label = $HBoxCourtoisie/Label


func _ready() -> void:
	set_camera_size()


func change_sprites(sprite_name: String) -> void:
	var new_sprites := ResourceLoader.load(
		"res://player/" + sprite_name + "_sprite_frames.tres") as SpriteFrames
	if new_sprites:
		sprite.sprite_frames = new_sprites


func set_camera_size() -> void:
	var ground_node: TileMapLayer = get_tree().get_first_node_in_group("grounds")
	var map_limits = ground_node.get_used_rect()
	var tile_size = ground_node.tile_set.tile_size
	camera2d.limit_right = map_limits.end.x * tile_size.x
	camera2d.limit_bottom = map_limits.end.y * tile_size.y 


func _physics_process(_delta: float) -> void:
	match current_state:
		State.IDLE:
			_state_idle()
		State.WALK:
			_state_walk()
		State.TARGET:
			_state_target()
		State.INTERACT:
			_state_interact()
		State.DISABLED:
			_state_disabled()


func _state_idle() -> void:
	velocity = Vector2.ZERO
	_play_animation("idle")

	var direction := _get_input_direction()
	if direction != Vector2.ZERO:
		facing_direction = direction
		_change_state(State.WALK)


func _state_walk() -> void:
	var direction := _get_input_direction()
	_state_walk_direction(direction)

	
func _state_target() -> void:
	if global_position.distance_to(target) <= 5:
		_change_state(State.IDLE)
		target_reached.emit()
	_state_walk_direction(target - global_position)


func _state_walk_direction(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		_change_state(State.IDLE)
		return

	facing_direction = direction
	velocity = direction.normalized() * speed
	_play_animation("walk")
	move_and_slide()


func _state_interact() -> void:
	velocity = Vector2.ZERO
	_play_animation("idle")
	# Waiting for interaction to complete. Controlled externally.


func _state_disabled() -> void:
	velocity = Vector2.ZERO
	# Completely inert: cutscene, menu, or battle transition.


func _change_state(new_state: State) -> void:
	current_state = new_state


func _get_input_direction() -> Vector2:
	return Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down"),
	)


func _play_animation(action: String) -> void:
	var direction_name := _direction_to_string(facing_direction)
	var anim_name := action + "_" + direction_name
	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
	else:
		push_error("Missing animation ", anim_name)


func _direction_to_string(direction: Vector2) -> String:
	# Determine the dominant axis for 4-directional facing
	if abs(direction.x) > abs(direction.y):
		return "right" if direction.x > 0 else "left"
	else:
		return "down" if direction.y >= 0 else "up"


func _string_to_direction(direction: String) -> Vector2:
	match direction:
		"up":
			return Vector2(0, -1)
		"down":
			return Vector2(0, 1)
		"left":
			return Vector2(-1, 0)
		"right":
			return Vector2(1, 0)
		_:
			push_error("Do not understand direction ", direction)
			return Vector2.ZERO


## Call this from external systems to disable/enable the player.
func set_disabled(disabled: bool) -> void:
	if disabled:
		_change_state(State.DISABLED)
	else:
		_change_state(State.IDLE)


## Call this when the player starts interacting with something.
func start_interaction() -> void:
	_change_state(State.INTERACT)


## Call this when the interaction is complete.
func end_interaction() -> void:
	_change_state(State.IDLE)


func modify_data(type: String, amount: int, is_heal: bool = false) -> void:
	var char_data: CharacterData = PartyManager.get_member_by_id("lancelot")
	var original_value: int
	var final_value: int
	var values: Array[int]
	if char_data:
		values = _update_char_data(char_data, type, amount, is_heal)
		original_value = values[0]
		final_value = values[1]
		if final_value == 0:
			die()
			return
		_update_bars(type, final_value)
		_spawn_damage_number(type, final_value - original_value)


func die() -> void:
	set_disabled(true)
	await get_tree().create_timer(2).timeout
	SceneManager.change_scene("res://scenes/dying/dying.tscn")


func die_animation() -> void:
	set_disabled(true)
	sprite.play("dying")


func _spawn_damage_number(type: String, diff: int) -> void:
	if diff == 0:
		return
		
	var text: String = str(diff)
	var hbox: HBoxContainer
	var label: Label

	match type:
		"prouesse":
			hbox = hbox_prouesse
			label = label_prouesse
		"amour":
			hbox = hbox_amour
			label = label_amour
		"courtoisie":
			hbox = hbox_courtoisie
			label = label_courtoisie
		_:
			push_error("Cannot understand type ", type)

	label.text = text
	label.add_theme_color_override("font_color", Color.GREEN if (diff >= 0) else Color.RED)
	hbox.z_index = 100
	hbox.visible = true

	# Add the label as a child of the sprite (Node2D), not the scene root.
	# This ensures the label uses Node2D coordinates, matching the sprite's position.
	var original_position = hbox.position
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(hbox, "position:y", -80.0, 1.5)
	tween.tween_property(hbox, "modulate:a", 0.0, 1.5)
	await tween.finished
	hbox.visible = false
	hbox.position = original_position
	hbox.modulate.a = 1


func _update_bars(type: String, final_value: int) -> void:
	var bars : BarsScreen = get_tree().get_first_node_in_group("bar_screens")
	if bars:
		bars.set_value(type, final_value)


func _update_char_data(char_data: CharacterData, type: String, amount: int, is_heal: bool = false) -> Array[int]:
	var diff: int = amount
	var original_value: int
	var final_value: int
	if not is_heal:
		diff = - diff
	match type:
		"prouesse":
			original_value = char_data.current_prouesse
			final_value = min(
					max(0, original_value + diff),
					char_data.max_prouesse)
			char_data.current_prouesse = final_value
		"amour":
			original_value = char_data.current_amour
			final_value = min(
					max(0, original_value + diff),
					char_data.max_amour)
			char_data.current_amour = final_value
		"courtoisie":
			original_value = char_data.current_courtoisie
			final_value = min(
					max(0, original_value + diff),
					char_data.max_courtoisie)
			char_data.current_courtoisie = final_value
		_:
			push_error("Cannot understand type ", type)
	return [original_value, final_value]


func go_to_point(target_position: Vector2) -> void:
	target = target_position
	_change_state(State.TARGET)


func face_direction(direction: String) -> void:
	set_disabled(false)
	facing_direction = _string_to_direction(direction)
