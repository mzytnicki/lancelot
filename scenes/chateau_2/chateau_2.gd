extends Node2D

@onready var _dialogue_box: CanvasLayer = $DialogueBox

@onready var _lancelot:      CharacterBody2D = $YSortGroup/Lancelot
@onready var _gauvain:       CharacterBody2D = $YSortGroup/Gauvain
@onready var _dame_1:        CharacterBody2D = $YSortGroup/Dame_1
@onready var _dame_2:        CharacterBody2D = $YSortGroup/Dame_2
@onready var _dame_3:        CharacterBody2D = $YSortGroup/Dame_3
@onready var _sword:         CharacterBody2D = $YSortGroup/Sword
@onready var _night_rect:    CanvasLayer     = $Night
@onready var _window_area_1: Area2D          = $WindowArea_1
@onready var _window_area_2: Area2D          = $WindowArea_2
@onready var _door_area:     Area2D          = $DoorArea
@onready var _window_mark_1: Marker2D        = $Window_1
@onready var _window_mark_2: Marker2D        = $Window_2
@onready var _dame_1_enter:  Marker2D        = $Dame_1_enter
@onready var _door:          Node2D          = $YSortGroup/ArchedDoor


static var _scene_number: int = 0

var _dame_thanked : bool = false


func _input(event: InputEvent) -> void:
	# Temporary: press B to start a test battle
	if event is InputEventKey and event.pressed and event.keycode == KEY_M:
		if _scene_number == 1:
			SceneManager.change_scene("res://scenes/chateau_2/chateau_2.tscn", "SmallBed")
		elif _scene_number == 2:
			SceneManager.change_scene("res://scenes/chateau_2/chateau_2.tscn", "SmallBed")
		elif _scene_number == 3:
			SceneManager.change_scene("res://scenes/chateau_2/chateau_2.tscn", "BeforeBed")
		else:
			SceneManager.change_scene("res://scenes/exterieur_dame/exterieur_dame.tscn")




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for npc in get_tree().get_nodes_in_group("npcs"):
		npc.interacted.connect(_on_npc_interacted)

	_window_area_1.body_entered.connect(_on_window_enter.bind(_window_mark_1.global_position))
	_window_area_2.body_entered.connect(_on_window_enter.bind(_window_mark_2.global_position))
	_door_area.body_entered.connect(_on_door_enter)

	match _scene_number:
		0:
			_entry_scene()
		1:
			_night_scene()
		2:
			_window_scene()
		3:
			_leaving()
	_scene_number += 1


func _night_scene():
	_lancelot.change_sprites("no_armor")
	_lancelot.start_interaction()
	_night_rect.visible = true
	await get_tree().create_timer(1).timeout
	_sword.global_position = _lancelot.global_position + Vector2(16, -120)
	_sword.visible = true
	await _sword.go_to("down", 80, true)
	await get_tree().create_timer(1).timeout

	_sword.play_animation("attack_right", true)
	await get_tree().create_timer(1).timeout

	
	var hero_data := BattlerData.new()
	hero_data.character_data = load("res://data/characters/lancelot.tres")
	hero_data.is_player_controlled = true

	var sword_data := EnemyData.new()
	sword_data = load("res://data/enemies/sword.tres")
	var enemy_data: BattlerData = BattlerData.from_enemy(sword_data)

	SceneManager.start_battle([hero_data], [enemy_data])


func _window_scene():
	_lancelot.change_sprites("no_armor")


func _entry_scene():
	_lancelot.change_sprites("no_armor")
	_dame_1.play_animation("idle_right", true)
	_dame_2.play_animation("idle_down", true)
	_dame_3.play_animation("idle_up", true)
	_gauvain.play_animation("idle_down", true)
	_lancelot.face_direction("up")
	_lancelot.start_interaction()

	await get_tree().create_timer(1).timeout
	_dame_1.go_to("right", 50, false)
	_dialogue_box.start_dialogue_lines(
		"La Demoiselle", [
			"Maintenant que mes gens ont ôté vos armes et vous ont revêtus de manteaux, partagez ce dîner avec nous.",
		]
	)
	await _dialogue_box.dialogue_finished
	await get_tree().create_timer(1).timeout
	_dame_2.play_animation("idle_left", true)
	_dialogue_box.start_dialogue_lines(
		"La Demoiselle", [
			"Seigneur Gauvain, vous qui êtes connu pour votre prouesse, pourquoi voyagez-vous avec un chevalier failli ?",
		]
	)
	await _dialogue_box.dialogue_finished
	await get_tree().create_timer(1).timeout
	_dame_3.play_animation("surprised_up", true)
	await get_tree().create_timer(1).timeout
	_dialogue_box.start_dialogue_lines(
		"La Demoiselle", [
			"Quel est le crime que votre companon a commis ?",
		]
	)
	await _dialogue_box.dialogue_finished
	await get_tree().create_timer(1).timeout
	_gauvain.play_animation("idle_right", true)
	var lines := DialogueLine.make_lines(
		"Gauvain", [
			"Je ne peux vous le révéler : il vous le dira s'il le souhaite.",
		]
	)
	lines[0].choices = ["Je n'ai commis aucun crime. J'ai été obligé de monter dans la charrette pour sauver la reine.",
		"Je préfère garder le silence."]
	_dialogue_box.start_dialogue(lines)
	var choice: int = await _dialogue_box.choice_made
	match choice:
		0:
			_lancelot.modify_data("prouesse", 10, true)
			await get_tree().create_timer(1).timeout
			_lancelot.modify_data("amour", 45, false)
		1:
			_lancelot.modify_data("prouesse", 10, false)
			await get_tree().create_timer(1).timeout
			_lancelot.modify_data("amour", 10, true)
		_:
			push_error("Cannot understand answer ", choice)
	await get_tree().create_timer(2).timeout
	
	_dame_1.go_to("up", 100, false)
	await get_tree().create_timer(1).timeout
	_dialogue_box.start_dialogue_lines(
		"La Demoiselle", [
			"Vous devez être épuisés.",
		]
	)
	await _dialogue_box.dialogue_finished
	_dame_1.go_to("right", 100, false)
	await get_tree().create_timer(1).timeout
	_dialogue_box.start_dialogue_lines(
		"La Demoiselle", [
			"Je vous conduits à vos lits.",
		]
	)
	await _dialogue_box.dialogue_finished
	_lancelot.end_interaction()


func _on_window_enter(body: Node2D, pos: Vector2) -> void:
	if body.is_in_group("player") and _scene_number == 3:
		_lancelot.start_interaction()
		await get_tree().create_timer(1).timeout
		_lancelot.go_to_point(pos)
		await get_tree().create_timer(1).timeout
		SceneManager.change_scene("res://scenes/cutscenes/guenievre.tscn")


func _leaving() -> void:
	_lancelot.change_sprites("no_armor")
	$BedArea.queue_free()
	
	# Hide unused characters
	_dame_2.queue_free()
	_dame_3.queue_free()
	_dame_1.visible = false
	_dame_1.global_position = Vector2.ZERO


func _on_npc_interacted(npc: NPC) -> void:
	if npc.npc_data.id == "gauvain_noarmor" and _scene_number == 4:
		_lancelot.start_interaction()
		_dialogue_box.start_dialogue(DialogueLine.make_lines(
			"Le chevalier", [
				"Vite, repartons à la recherche de la reine. Nous n'avons que trop tardé.",
			]
		))
		await _dialogue_box.dialogue_finished
		_dialogue_box.start_dialogue(DialogueLine.make_lines(
			"Gauvain", [
				"Comment ferez-vous ? Le nain est reparti. Vous n'avez pas de cheval.",
			]
		))
		await _dialogue_box.dialogue_finished
		_dame_1.global_position = _dame_1_enter.global_position
		_dame_1.visible = true
		await _dame_1.go_to("up", 170, true)
		_lancelot.face_direction("down")
		_lancelot.start_interaction()
		await get_tree().create_timer(1).timeout
		_dialogue_box.start_dialogue(DialogueLine.make_lines(
			"La Demoiselle", [
				"Je vous offre un cheval et une lance. Vous pouvez poursuivre votre quête.",
			]
		))
		await _dialogue_box.dialogue_finished
		_scene_number += 1
		_lancelot.end_interaction()
		_door.open()
	elif npc.npc_data.id == "dame_3" and _scene_number == 5:
		_lancelot.start_interaction()
		_dialogue_box.start_dialogue(DialogueLine.make_lines(
			"Le chevalier", [
				"Demoiselle, soyez vivement remerciée de votre accueil et de votre générosité.",
			]
		))
		await _dialogue_box.dialogue_finished
		_lancelot.modify_data("amour", 10, true)
		await get_tree().create_timer(1).timeout
		_lancelot.modify_data("courtoisie", 40, false)
		await get_tree().create_timer(1).timeout
		_lancelot.end_interaction()
		_dame_thanked = true


func _on_door_enter(body: Node2D) -> void:
	if body.is_in_group("player") and _scene_number == 5:
		if not _dame_thanked:
			_lancelot.start_interaction()
			_lancelot.modify_data("courtoisie", 20, false)
			await get_tree().create_timer(1).timeout
		SceneManager.change_scene("res://scenes/exterieur_dame/exterieur_dame.tscn")
