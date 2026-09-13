extends Node
## Manages scene transitions with fade effects.
## Registered as an autoload. Accessible as SceneManager from anywhere.

signal transition_started
signal transition_finished

# @onready var _color_rect: ColorRect = $TransitionLayer/ColorRect
@onready var _anim_player: AnimationPlayer = $TransitionLayer/AnimationPlayer

var _target_scene_path: String = ""
var _target_spawn_point: String = ""
var _is_transitioning: bool = false
var _previous_scene_path: String = ""
var _previous_player_position: Vector2 = Vector2.ZERO


func change_scene(scene_path: String, spawn_point: String = "default") -> void:
	if _is_transitioning:
		return

	_is_transitioning = true
	_target_scene_path = scene_path
	_target_spawn_point = spawn_point

	transition_started.emit()
	_anim_player.play("fade_out")
	await _anim_player.animation_finished

	get_tree().change_scene_to_file(_target_scene_path)

	# Wait for the new scene to be fully loaded and added to the tree.
	# change_scene_to_file() is deferred, so we need to wait for the swap.
	await get_tree().scene_changed

	_place_player_at_spawn()

	_anim_player.play("fade_in")
	await _anim_player.animation_finished

	_is_transitioning = false
	transition_finished.emit()


func _place_player_at_spawn() -> void:
	# Find the spawn point marker in the new scene
	var spawn_markers := get_tree().get_nodes_in_group("spawn_points")
	for marker in spawn_markers:
		if marker.name == _target_spawn_point:
			var player := get_tree().get_first_node_in_group("player")
			if player:
				player.global_position = marker.global_position
			return

	# If no matching spawn point, use "default"
	for marker in spawn_markers:
		if marker.name == "default":
			var player := get_tree().get_first_node_in_group("player")
			if player:
				player.global_position = marker.global_position
			return

	# Neither the requested spawn point nor a "default" marker exists.
	# Log a clear warning so the missing marker is easy to spot.
	push_warning("SceneManager: no spawn point '%s' and no 'default' in %s; player position unchanged." % [_target_spawn_point, _target_scene_path])


func start_battle(party_data: Array[BattlerData], enemy_data: Array[BattlerData]) -> void:
	if _is_transitioning:
		return

	_is_transitioning = true

	# Remember where we were
	var player := get_tree().get_first_node_in_group("player")
	if player:
		_previous_player_position = player.global_position
	_previous_scene_path = get_tree().current_scene.scene_file_path

	transition_started.emit()
	_anim_player.play("fade_out")
	await _anim_player.animation_finished

	get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")
	await get_tree().scene_changed
	
	MusicManager.remember_track()
	MusicManager.play_music("res://audio/music/battle_theme.mp3")

	# Initialize the battle with encounter data
	var battle_scene := get_tree().current_scene
	if battle_scene.has_method("initialize_battle"):
		battle_scene.initialize_battle(party_data, enemy_data)
#		battle_scene.initialize_battle(
#			encounter_data.get("party", []),
#			encounter_data.get("enemies", []),
#		)

	_anim_player.play("fade_in")
	await _anim_player.animation_finished
	_is_transitioning = false
	transition_finished.emit()


func return_from_battle() -> void:
	if _previous_scene_path.is_empty():
		return

	change_scene(_previous_scene_path, "default")
	# After scene loads, restore player position
	await transition_finished
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.global_position = _previous_player_position
		
	MusicManager.resume_previous_track()
