extends Node2D
## The town of Willowbrook, Crystal Saga's starting village.

@onready var _dialogue_box: CanvasLayer = $DialogueBox


func _ready() -> void:
	_dialogue_box.dialogue_finished.connect(_on_dialogue_finished)

	for npc in get_tree().get_nodes_in_group("npcs"):
		npc.interacted.connect(_on_npc_interacted)


func _on_npc_interacted(npc: NPC) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("start_interaction"):
		player.start_interaction()

	if npc.npc_data and not npc.npc_data.dialogue.is_empty():
		_dialogue_box.start_dialogue(npc.npc_data.dialogue)
		var lines := _get_dialogue_for_npc(npc)
		_dialogue_box.start_dialogue(lines)
		if npc.npc_data.id == "fynn" and GameManager.has_flag("pendant_found") and not GameManager.has_flag("pendant_returned"):
			_dialogue_box.dialogue_finished.connect(_on_fynn_turn_in_dialogue_finished, CONNECT_ONE_SHOT)


func _get_dialogue_for_npc(npc: NPC) -> Array[DialogueLine]:
	match npc.npc_data.id:
		"elder_maren":
			return _get_elder_dialogue()
		"fynn":
			return _get_fynn_dialogue()
		_:
			return npc.npc_data.dialogue


func _get_fynn_dialogue() -> Array[DialogueLine]:
	if GameManager.has_flag("pendant_returned"):
		return _make_lines("Fynn", ["Thank you again for finding my pendant!"])
	elif GameManager.has_flag("pendant_found"):
		return _make_lines("Fynn", [
			"You found it! My pendant! Thank you so much!",
			"Please, take this as a reward.",
		])
	elif GameManager.has_flag("talked_to_fynn"):
		return _make_lines("Fynn", ["Any luck finding my pendant in the Whisperwood?"])
	else:
		GameManager.set_flag("talked_to_fynn")
		var quest: QuestData = load("res://data/quests/lost_pendant.tres")
		if quest:
			QuestManager.start_quest(quest)
		return _make_lines("Fynn", [
			"I lost something precious in the Whisperwood...",
			"A pendant, silver with a blue stone.",
			"If you find it, I'd be forever grateful.",
		])


func _make_lines(speaker: String, texts: Array[String]) -> Array[DialogueLine]:
	var lines: Array[DialogueLine] = []
	for text in texts:
		var line := DialogueLine.new()
		line.speaker_name = speaker
		line.text = text
		lines.append(line)
	return lines


func _on_dialogue_finished() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("end_interaction"):
		player.end_interaction()


func _input(event: InputEvent) -> void:
	# Temporary: press B to start a test battle
	if event is InputEventKey and event.pressed and event.keycode == KEY_B:
		_start_test_battle()


func _start_test_battle() -> void:
	var hero_data := BattlerData.new()
	hero_data.character_data = load("res://data/characters/aiden.tres")
	hero_data.is_player_controlled = true

	# Create a temporary enemy
	var enemy_char := CharacterData.new()
	enemy_char.display_name = "Slime"
	enemy_char.max_hp = 30
	enemy_char.attack = 5
	enemy_char.defense = 2
	enemy_char.speed = 4

	var enemy_data := BattlerData.new()
	enemy_data.character_data = enemy_char
	enemy_data.is_player_controlled = false

#	SceneManager.start_battle({
#		party = [hero_data],
#		enemies = [enemy_data],
#	})
	SceneManager.start_battle([hero_data], [enemy_data])


# Elder Maren was created in Module 10 with npc_data.id = "elder_maren".
# Talking to her starts the main quest and sets its first objective flag.
func _get_elder_dialogue() -> Array[DialogueLine]:
	if not QuestManager.is_quest_active("crystal_resonance") and not QuestManager.is_quest_complete("crystal_resonance"):
		var quest: QuestData = load("res://data/quests/crystal_resonance.tres")
		if quest:
			QuestManager.start_quest(quest)
	GameManager.set_flag("talked_to_elder")
	return _make_lines("Elder Maren", [
		"The crystals have grown restless.",
		"Their song points beyond Whisperwood, to the old cavern.",
		"Please, find the source before the resonance breaks.",
	])


func _on_fynn_turn_in_dialogue_finished() -> void:
	if QuestManager.turn_in_quest_by_id("lost_pendant"):
		var pendant := load("res://data/items/pendant.tres") as ItemData
		if pendant:
			InventoryManager.remove_item(pendant)
