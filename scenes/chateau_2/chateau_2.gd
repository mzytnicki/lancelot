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
@onready var _window_mark_1: Marker2D        = $Window_1
@onready var _window_mark_2: Marker2D        = $Window_2


static var _scene_number: int = 0


func _input(event: InputEvent) -> void:
	# Temporary: press B to start a test battle
	if event is InputEventKey and event.pressed and event.keycode == KEY_M:
		if _scene_number == 1:
			SceneManager.change_scene("res://scenes/chateau_2/chateau_2.tscn", "SmallBed")
		elif _scene_number == 2:
			SceneManager.change_scene("res://scenes/chateau_2/chateau_2.tscn", "SmallBed")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_window_area_1.body_entered.connect(_on_window_enter.bind(_window_mark_1.global_position))
	_window_area_2.body_entered.connect(_on_window_enter.bind(_window_mark_2.global_position))
	match _scene_number:
		0:
			_entry_scene()
		1:
			_night_scene()
		2:
			_window_scene()
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
