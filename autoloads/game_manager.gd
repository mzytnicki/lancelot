extends Node
## Tracks global game state via boolean flags. Autoload as GameManager.

signal flag_changed(flag_name: String, value: bool)

var _flags: Dictionary = {}


func set_flag(flag_name: String, value: bool = true) -> void:
	var old_value: bool = _flags.get(flag_name, false)
	_flags[flag_name] = value
	if old_value != value:
		flag_changed.emit(flag_name, value)


func get_flag(flag_name: String) -> bool:
	return _flags.get(flag_name, false)


func has_flag(flag_name: String) -> bool:
	return _flags.get(flag_name, false)


func clear_flag(flag_name: String) -> void:
	set_flag(flag_name, false)


func make_world_flag(scene_key: String, object_id: String, state: String) -> String:
	return "world.%s.%s.%s" % [scene_key, object_id, state]


func get_all_flags() -> Dictionary:
	return _flags.duplicate()


func load_flags(data: Dictionary) -> void:
	_flags = data.duplicate()
