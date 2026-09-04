extends Area2D

var keu_met : bool = false

@onready var _keu: NPC = $"../YSortGroup/Keu"
@onready var _gauvain: NPC = $"../YSortGroup/Gauvain"
@onready var _lancelot: CharacterBody2D = $"../YSortGroup/Lancelot"
@onready var _lancelot_cheval: CharacterBody2D = $"../YSortGroup/Lancelot_cheval"
@onready var _dialogue_box: CanvasLayer = $"../DialogueBox"




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _make_lines(speaker: String, texts: Array[String]) -> Array[DialogueLine]:
	var lines: Array[DialogueLine] = []
	for text in texts:
		var line := DialogueLine.new()
		line.speaker_name = speaker
		line.text = text
		lines.append(line)
	return lines


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not keu_met:
		_keu.disable()
		_keu.play_animation("idle_hurt")
		_lancelot.start_interaction()
		await get_tree().create_timer(1).timeout
		var distance: Vector2 = Vector2(50, 0)
		_lancelot.go_to_point(_keu._sprite.global_position + distance)
		await get_tree().create_timer(2).timeout
		_lancelot.face_direction("left")
		keu_met = true
		await get_tree().create_timer(0.5).timeout
		_lancelot.start_interaction()
		_dialogue_box.start_dialogue(_make_lines(
			"Le Chevalier", [
				"Que vous est-il arrivé ?",
			]
		))
		await _dialogue_box.dialogue_finished
		_dialogue_box.start_dialogue(_make_lines(
			"Keu", [
				"Je n'ai pas pu protéger la reine. Il l'a emmenée.",
			]
		))
		await _dialogue_box.dialogue_finished
		_dialogue_box.start_dialogue(_make_lines(
			"Le Chevalier", [
				"Où ?",
			]
		))
		await _dialogue_box.dialogue_finished
		_dialogue_box.start_dialogue(_make_lines(
			"Keu", [
				"Au pays d'où on ne revient pas.",
			]
		))
		await _dialogue_box.dialogue_finished
		_dialogue_box.start_dialogue(_make_lines(
			"Le Chevalier", [
				"Où est-ce ?",
			]
		))
		await _dialogue_box.dialogue_finished
		_dialogue_box.start_dialogue(_make_lines(
			"Keu", [
				"C'est...",
			]
		))
		await _dialogue_box.dialogue_finished
		_keu.play_animation("lying")
		await get_tree().create_timer(1).timeout
		_keu.queue_free()

		_gauvain.visible = true
		_gauvain.go_to("right", 400, true)
		_lancelot.face_direction("left")
		_lancelot.start_interaction()
		await get_tree().create_timer(1).timeout
		_dialogue_box.start_dialogue_lines(
			"Gauvain", [
				"Où est votre cheval ?",
			]
		)
		await _dialogue_box.dialogue_finished
		_dialogue_box.start_dialogue_lines(
			"Le Chevalier", [
				"Il est mort d'épuisement.",
			]
		)
		await _dialogue_box.dialogue_finished
		var lines := _make_lines(
			"Gauvain", [
				"Je vous prête l'un des miens.",
				"Lequel voulez-vous ? [i]Appuyez sur 'Entrée' pour valider.[/i]",
			]
		)
		lines[1].choices = ["Je vous remercie. Je prends celui que vous ne voulez pas.",
			"Grand merci. Le plus proche, et je repars.",
			"Celui-ci."]
		_dialogue_box.start_dialogue(lines)
		var choice: int = await _dialogue_box.choice_made
		await get_tree().create_timer(1).timeout
		match choice:
			0:
				_lancelot.modify_data("courtoisie", 10, true)
			1:
				_lancelot.modify_data("amour", 10, true)
			2:
				_lancelot.modify_data("courtoisie", 10, false)
			_:
				push_error("Cannot understand answer ", choice)
		await get_tree().create_timer(2).timeout
		_lancelot.end_interaction()

		_lancelot.visible = false
		_lancelot.remove_from_group("player")
		_lancelot_cheval.set_disabled(false)
		_lancelot_cheval.global_position = _lancelot.global_position
		_lancelot_cheval.facing_direction = _lancelot.facing_direction
		_lancelot.queue_free()
		_lancelot_cheval.visible = true
		_lancelot_cheval.add_to_group("player")
