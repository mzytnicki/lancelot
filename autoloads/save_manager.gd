extends Node
## Handles saving and loading game state to JSON files.
## Registered as autoload, accessible as SaveManager.

const SAVE_DIR := "user://saves/"
const MAX_SLOTS := 3


func save_game(slot: int) -> bool:
	# Creates the save directory (and any parent directories) if it doesn't
	# exist yet. Safe to call even if the directory already exists.
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

	var save_data: Dictionary = {
		version = 1,
		timestamp = Time.get_datetime_string_from_system(),
		scene_path = "",
		player_position = {x = 0.0, y = 0.0},
		game_flags = {},
		inventory = {},
		party = {},
		quests = {},
	}

	# Gather state from autoloads
	save_data.game_flags = GameManager.to_save_data()
	save_data.inventory = InventoryManager.to_save_data()
	save_data.party = PartyManager.to_save_data()
	save_data.quests = QuestManager.to_save_data()

	# Scene and player position
	var tree := Engine.get_main_loop() as SceneTree
	if tree and tree.current_scene:
		save_data.scene_path = tree.current_scene.scene_file_path
	var player := tree.get_first_node_in_group("player") if tree else null
	if player:
		save_data.player_position = {
			x = player.global_position.x,
			y = player.global_position.y,
		}

	# Write to file
	var path := SAVE_DIR + "save_" + str(slot) + ".json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("SaveManager: failed to open " + path + " for writing")
		return false

	var json_string := JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()
	print("Game saved to slot " + str(slot))
	return true


func load_game(slot: int) -> bool:
	var path := SAVE_DIR + "save_" + str(slot) + ".json"

	if not FileAccess.file_exists(path):
		push_error("SaveManager: save file not found: " + path)
		return false

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("SaveManager: failed to open " + path)
		return false

	var json_string := file.get_as_text()
	file.close()

	# Godot's JSON class works in two steps: json.parse() attempts to parse
	# the string (returns OK on success), then json.data holds the result as
	# a Variant. A valid JSON root can be an array, number, string, bool, null,
	# or object, so check that it is a Dictionary before using it as save data.
	var json := JSON.new()
	var error := json.parse(json_string)
	if error != OK:
		push_error("SaveManager: JSON parse error: " + json.get_error_message())
		return false

	var parsed: Variant = json.data
	if not parsed is Dictionary:
		push_error("SaveManager: save root must be a Dictionary.")
		return false

	var save_data: Dictionary = parsed
	if not save_data.has("version"):
		push_error("Save data missing version field")
		return false

	# Restore state to autoloads
	GameManager.from_save_data(save_data.get("game_flags", {}))
	InventoryManager.from_save_data(save_data.get("inventory", {}))
	PartyManager.from_save_data(save_data.get("party", {}))
	QuestManager.from_save_data(save_data.get("quests", {}))

	# Load the saved scene
	var scene_path: String = save_data.get("scene_path", "")
	if scene_path:
		var tree := Engine.get_main_loop() as SceneTree
		tree.change_scene_to_file(scene_path)
		# change_scene_to_file() is deferred. Wait for the tree to update.
		await tree.scene_changed

		# Restore player position
		var pos_data: Dictionary = save_data.get("player_position", {})
		var player := tree.get_first_node_in_group("player")
		if player:
			player.global_position = Vector2(
				pos_data.get("x", 0.0),
				pos_data.get("y", 0.0),
			)

	print("Game loaded from slot " + str(slot))
	return true


func get_slot_info(slot: int) -> Dictionary:
	var path := SAVE_DIR + "save_" + str(slot) + ".json"
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}

	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return {}
	file.close()

	var parsed: Variant = json.data
	if not parsed is Dictionary:
		return {}

	var data: Dictionary = parsed
	return {
		timestamp = data.get("timestamp", ""),
		scene_path = data.get("scene_path", ""),
	}


func slot_exists(slot: int) -> bool:
	return FileAccess.file_exists(SAVE_DIR + "save_" + str(slot) + ".json")
