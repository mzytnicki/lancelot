extends Node2D
## Le château du début.

@onready var _bars_screen:  CanvasLayer = $BarsScreen

@onready var _dialogue_box: CanvasLayer = $DialogueBox

@onready var _lancelot:  CharacterBody2D = $YSortGroup/Lancelot

@onready var _meleagant: NPC = $YSortGroup/Meleagant
@onready var _guenievre: NPC = $YSortGroup/Guenievre
@onready var _keu:       NPC = $YSortGroup/Keu
@onready var _gauvain:   NPC = $YSortGroup/Gauvain
@onready var _knight_1:  NPC = $YSortGroup/Knight_1
@onready var _knight_2:  NPC = $YSortGroup/Knight_2
@onready var _dame_3:    NPC = $YSortGroup/Dame_3
@onready var _dame_4:    NPC = $YSortGroup/Dame_4



func _ready() -> void:
	_lancelot.start_interaction()
	_knight_1.play_animation("idle_up", true)
	_knight_2.play_animation("idle_up", true)
	_dame_3.play_animation("idle_up", true)
	_dame_4.play_animation("idle_up", true)

		
	var lancelot_data := ResourceLoader.load(
		"res://data/characters/lancelot.tres", "", ResourceLoader.CACHE_MODE_IGNORE,
	) as CharacterData
	if lancelot_data:
		lancelot_data.current_hp = lancelot_data.max_hp
		lancelot_data.current_mp = lancelot_data.max_mp
		lancelot_data.current_prouesse = lancelot_data.max_prouesse
		lancelot_data.current_amour = lancelot_data.max_amour
		lancelot_data.current_courtoisie = lancelot_data.max_courtoisie
		lancelot_data.current_xp = 0
		PartyManager.add_member(lancelot_data)
	
	_meleagant.go_to("left", 200, true)
	await get_tree().create_timer(2).timeout
	_dialogue_box.start_dialogue(_make_lines(
		"Méléagant", [
			"Arthur, je détiens des prisonniers de ton royaume et il n'est rien que tu puisses faire pour les libérer.   [i](Pressez 'X' pour continuer.)[/i]",
			"Aujourd'hui, j'enlève la reine et tu n'y pourras rien non plus, à moins que l'un de tes chevaliers soit assez vaillant pour l'emporter sur moi."
		]
	))
	await _dialogue_box.dialogue_finished
	_meleagant.go_to("right", 250, false)
	_guenievre.go_to("right", 250, false)
	await get_tree().create_timer(1).timeout
	_keu.surprise()
	await get_tree().create_timer(1).timeout
	_dialogue_box.start_dialogue(_make_lines(
		"Keu", [
			"Arthur, Je suis le sénéchal: c'est à moi que revient l'honneur d'y aller."
		]
	))
	await _dialogue_box.dialogue_finished
	await _keu.go_to("up", 30, true)
	_keu.go_to("right", 400, true)
	_gauvain.surprise()
	_dialogue_box.start_dialogue(_make_lines(
		"Gauvain", [
			"Sire, nous ne pouvons pas laisser Keu y aller tout seul.",
			"Tous les chevaliers du royaume de Gorre doivent se lancer au secours de la reine."
		]
	))
	await _dialogue_box.dialogue_finished
	SceneManager.change_scene("res://scenes/exterieur_charrette/exterieur_charrette.tscn")



func _input(event: InputEvent) -> void:
	# Temporary: press B to start a test battle
	if event is InputEventKey and event.pressed and event.keycode == KEY_B:
		#_bars_screen.set_prouesse_to(50)
		_lancelot.modify_data("amour", 10, false)


func _make_lines(speaker: String, texts: Array[String]) -> Array[DialogueLine]:
	var lines: Array[DialogueLine] = []
	for text in texts:
		var line := DialogueLine.new()
		line.speaker_name = speaker
		line.text = text
		lines.append(line)
	return lines


func _initialize_fresh_state() -> void:
	# Reset all autoloads to starting state
	GameManager.from_save_data({})

	# Reset inventory
	InventoryManager.from_save_data({gold = 100, items = []})
	var potion: ItemData = load("res://data/items/potion.tres")
	if potion:
		InventoryManager.add_item(potion, 3)

	# Reset party to just the hero
	PartyManager.from_save_data({members = []})
	var lancelot := ResourceLoader.load(
		"res://data/characters/lancelot.tres", "", ResourceLoader.CACHE_MODE_IGNORE,
	) as CharacterData
	if lancelot:
		lancelot.current_hp = lancelot.max_hp
		lancelot.current_mp = lancelot.max_mp
		lancelot.current_xp = 0
		PartyManager.add_member(lancelot)

	# Reset quests
	QuestManager.from_save_data({active = [], completed = [], turned_in = []})
