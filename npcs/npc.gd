extends CharacterBody2D
class_name NPC
## A non-player character that can be interacted with.

enum State { IDLE, WALK, ANIMATION, INTERACT, DISABLED }

signal interacted(npc: NPC)
signal walk_done


@export var npc_data: NPCData
@export var speed: float = 200.0

var _current_state:    State   = State.IDLE
var _player_in_range:  bool    = false
var _target:           Vector2 = Vector2.ZERO
var _facing_direction: Vector2 = Vector2.DOWN  # Vector2(0, 1), positive Y is downward in Godot
var _track_end:        bool    = true


@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _interaction_prompt: Label = $InteractionPrompt
@onready var _interaction_zone: Area2D = $InteractionZone


func _ready() -> void:
	_interaction_zone.body_entered.connect(_on_player_entered)
	_interaction_zone.body_exited.connect(_on_player_exited)
	_interaction_prompt.visible = false

	if npc_data:
		_apply_npc_data()


func _physics_process(_delta: float) -> void:
	match _current_state:
		State.IDLE:
			_state_idle()
		State.WALK:
			_state_walk()



func _change_state(new_state: State) -> void:
	_current_state = new_state


func disable() -> void:
	_change_state(State.DISABLED)


func _state_idle() -> void:
	velocity = Vector2.ZERO
	_play_animation("idle")


func _state_walk() -> void:
	var direction: Vector2 = _sprite.global_position.direction_to(_target)
	var distance: float = _sprite.global_position.distance_to(_target)

	if distance <= 5:
		_change_state(State.IDLE)
		if _track_end:
			_track_end = false
			walk_done.emit()
		return

	_facing_direction = direction
	velocity = direction.normalized() * speed
	_play_animation("walk")
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range:
		return

	if event.is_action_pressed("interact"):
		_face_player()
		get_viewport().set_input_as_handled()
		interacted.emit(self)


func _apply_npc_data() -> void:
	if npc_data.sprite_frames:
		_sprite.sprite_frames = npc_data.sprite_frames

	# Set initial facing direction
	_facing_direction = npc_data.facing_direction
	var dir_name := _direction_to_string(npc_data.facing_direction)
	var idle_anim := "idle_" + dir_name
	if _sprite.sprite_frames and _sprite.sprite_frames.has_animation(idle_anim):
		_sprite.play(idle_anim)


func _face_player() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return

	_face_something(player.global_position)


func _face_something(direction: Vector2) -> void:
	var dir_name := _direction_to_string(direction - _sprite.global_position)
	face_direction(dir_name)


func face_direction(direction: String) -> void:
	var idle_anim := "idle_" + direction
	if _sprite.sprite_frames and _sprite.sprite_frames.has_animation(idle_anim):
		_sprite.play(idle_anim)
	_facing_direction = _direction_from_string(direction)


func _direction_to_string(direction: Vector2) -> String:
	if abs(direction.x) > abs(direction.y):
		return "right" if direction.x > 0 else "left"
	else:
		return "down" if direction.y >= 0 else "up"


func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		_interaction_prompt.visible = true


func _on_player_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_interaction_prompt.visible = false


func _direction_from_string(direction: String) -> Vector2:
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
			push_error("Cannot parse direction ", direction)
			return Vector2.ZERO


func _play_animation(action: String) -> void:
	var direction_name := _direction_to_string(_facing_direction)
	var anim_name := action + "_" + direction_name
	play_animation(anim_name)


func play_animation(anime_name: String, idle: bool = false) -> void:
	if _sprite.sprite_frames.has_animation(anime_name):
		if idle:
			_change_state(State.ANIMATION)
		_sprite.play(anime_name)
	else:
		push_error("Cannot find animation ", anime_name)


func surprise() -> void:
	play_animation("surprise", true)
#	walk_done.emit()


func go_to(direction: String, distance: int, track: bool) -> void:
	var original_pos: Vector2 = _sprite.global_position
	var direction_float := _direction_from_string(direction)
	_target = original_pos + direction_float * distance
	_track_end = track
	_face_something(_target)
	_change_state(State.WALK)
	if track:
		await walk_done
