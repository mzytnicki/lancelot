extends Node2D
## The town of Willowbrook, Crystal Saga's starting village.

@onready var _dialogue_box: CanvasLayer = $DialogueBox
@onready var _shop_ui: CanvasLayer = $ShopUI         # Instance of shop_ui.tscn (add to scene)

func _ready() -> void:
	MusicManager.play_music("res://audio/music/town_theme.mp3")
	_dialogue_box.dialogue_finished.connect(_on_dialogue_finished)

	for npc in get_tree().get_nodes_in_group("npcs"):
		npc.interacted.connect(_on_npc_interacted)


func _on_npc_interacted(npc: NPC) -> void:
	# Shopkeeper and innkeeper open modal UI instead of plain dialogue.
	if npc.npc_data.id == "shopkeeper":
		var shop_data: ShopData = load("res://data/shops/willowbrook_shop.tres")
		if shop_data:
			_open_shop(shop_data)
		return
	if npc.npc_data.id == "innkeeper":
		_handle_inn(npc)
		return

	# Everyone else gets flag-aware dialogue (the Module 20 dispatcher).
	var lines := _get_dialogue_for_npc(npc)
	_dialogue_box.start_dialogue(lines)

	# Arm per-NPC one-shot follow-ups that fire when the dialogue closes.
	if npc.npc_data.id == "fynn" and GameManager.has_flag("pendant_found") and not GameManager.has_flag("pendant_returned"):
		_dialogue_box.dialogue_finished.connect(_on_fynn_turn_in_dialogue_finished, CONNECT_ONE_SHOT)
	elif npc.npc_data.id == "lira" and GameManager.has_flag("lira_ready_to_join") and not GameManager.has_flag("lira_joined"):
		_dialogue_box.dialogue_finished.connect(_recruit_lira, CONNECT_ONE_SHOT)


func _recruit_lira() -> void:
	GameManager.set_flag("lira_joined")
	var lira: CharacterData = load("res://data/characters/lira.tres")
	if lira:
		PartyManager.add_member(lira)
		print("Lira joined the party!")


func _get_dialogue_for_npc(npc: NPC) -> Array[DialogueLine]:
	match npc.npc_data.id:
		"elder_maren":
			return _get_elder_dialogue()
		"fynn":
			return _get_fynn_dialogue()
		"lira":
			return _get_lira_dialogue()
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


func _get_lira_dialogue() -> Array[DialogueLine]:
	if GameManager.has_flag("lira_joined"):
		return _make_lines("Lira", ["Ready to go when you are!"])

	if GameManager.has_flag("lira_ready_to_join"):
		return _make_lines("Lira", [
			"I've been studying the crystal formations nearby.",
			"They resonate with a strange energy...",
			"If you're heading to the Crystal Cavern, I'd like to come along.",
			"My magic could be useful!",
		])

	if GameManager.has_flag("lira_intro_seen"):
		GameManager.set_flag("lira_ready_to_join")
		return _make_lines("Lira", [
			"I've been studying the crystal formations nearby.",
			"They resonate with a strange energy...",
			"If you're heading to the Crystal Cavern, I'd like to come along.",
			"My magic could be useful!",
		])

	# First meeting
	GameManager.set_flag("lira_intro_seen")
	return _make_lines("Lira", [
		"Oh, hello! I'm Lira, a scholar from the capital.",
		"I came to Willowbrook to study the ancient crystals.",
		"Talk to me again if you're interested in what I've found.",
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


func _open_shop(shop_data: ShopData) -> void:
	_shop_ui.open_shop(shop_data)
	if not _shop_ui.shop_closed.is_connected(_on_shop_closed):
		_shop_ui.shop_closed.connect(_on_shop_closed, CONNECT_ONE_SHOT)


func _on_shop_closed() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("end_interaction"):
		player.end_interaction()


func _handle_inn(npc: NPC) -> void:
	var lines := _make_lines("Old Brennan", [
	"Rest for the night? That'll be 10 gold.",
	])
	# Add a choice to the last line
	lines[0].choices = ["Yes (10g)", "No thanks"]
	_dialogue_box.start_dialogue(lines)
	var choice: int = await _dialogue_box.choice_made

	if choice == 0:  # Yes
		if InventoryManager.spend_gold(10):
			for member in PartyManager.get_members():
				member.current_hp = member.max_hp
				member.current_mp = member.max_mp
			_dialogue_box.start_dialogue(_make_lines("Old Brennan", ["Rest well, traveler."]))
		else:
			_dialogue_box.start_dialogue(_make_lines("Old Brennan", ["Seems you're a bit short."]))

	# Release player control once the closing line finishes, the same way the
	# shop does. Without this the player stays stuck in the INTERACT state.
	await _dialogue_box.dialogue_finished
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("end_interaction"):
		player.end_interaction()
