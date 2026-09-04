extends Node2D

@onready var _dialogue_box: CanvasLayer = $DialogueBox

@onready var _lancelot:  CharacterBody2D = $YSortGroup/Lancelot
@onready var _gauvain:  CharacterBody2D = $YSortGroup/Gauvain
@onready var _dame_1:  CharacterBody2D = $YSortGroup/Dame_1
@onready var _dame_2:  CharacterBody2D = $YSortGroup/Dame_2
@onready var _dame_3:  CharacterBody2D = $YSortGroup/Dame_3


func _make_lines(speaker: String, texts: Array[String]) -> Array[DialogueLine]:
	var lines: Array[DialogueLine] = []
	for text in texts:
		var line := DialogueLine.new()
		line.speaker_name = speaker
		line.text = text
		lines.append(line)
	return lines


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	var lines := _make_lines(
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



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
