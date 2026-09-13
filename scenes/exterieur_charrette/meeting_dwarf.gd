extends Area2D

var dwarf_met : bool = false

@onready var _gauvain: NPC = $"../YSortGroup/Gauvain"
@onready var _lancelot: CharacterBody2D = $"../YSortGroup/Lancelot"
@onready var _dwarf: NPC = $"../YSortGroup/Nain"
@onready var _peasant_1:  CharacterBody2D = $"../YSortGroup/Peasant_1"
@onready var _peasant_2:  CharacterBody2D = $"../YSortGroup/Peasant_2"
@onready var _peasant_3:  CharacterBody2D = $"../YSortGroup/Peasant_3"
@onready var _dialogue_box: CanvasLayer = $"../DialogueBox"


# Called when tamies. Je l’aime, mais je suis passée au dessus de ces sentiments pour pleins de raisons différentes. Eux, ils attendent he node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not dwarf_met:
		_dwarf.disable()
		_lancelot.start_interaction()
		await get_tree().create_timer(1).timeout
		var distance: Vector2 = Vector2(110, 0)
		_lancelot.go_to_point(_dwarf._sprite.global_position - distance)
		await get_tree().create_timer(2).timeout
		_lancelot.face_direction("right")
		_lancelot.start_interaction()
		dwarf_met = true
		_dialogue_box.start_dialogue_lines(
			"Le Chevalier", [
				"Avez-vous vu passer un homme emmenant la reine ?",
			]
		)
		await _dialogue_box.dialogue_finished
		_dialogue_box.start_dialogue_lines(
			"Le Nain", [
				"Je les ai vus passer. Je vous dirai où ils sont allés si vous montez dans cette charrette.",
			]
		)
		await _dialogue_box.dialogue_finished
		_gauvain.global_position = _lancelot.global_position - Vector2(350, 50)
		_gauvain.go_to("right", 320, true)
		await get_tree().create_timer(1).timeout
		_dialogue_box.start_dialogue_lines(
			"Gauvain", [
				"La charette, c'est pour les condamnés. Il est hors de question que je me déshonore en montant dans un tel lieu.",
			]
		)
		await _dialogue_box.dialogue_finished
		_dialogue_box.start_dialogue_lines(
			"Le Nain", [
				"Si vous ne montez pas, vous ne trouverez jamais la reine.",
			]
		)
		await _dialogue_box.dialogue_finished
		_dialogue_box.start_dialogue_lines(
			"Gauvain", [
				"Chevalier, ne montez pas, ce n'est pas raisonnable. Vous perdrez tout honneur si vous acceptez.",
			]
		)
		await _dialogue_box.dialogue_finished
		var lines := DialogueLine.make_lines("Le Chevalier", ["Que faire ?"])
		lines[0].choices = ["Je dois le faire pour la reine.",
			"Nain, avance et je te suivrai, mais je ne monterai pas dans la charrette."]
		_dialogue_box.start_dialogue(lines)
		var choice: int = await _dialogue_box.choice_made
		await get_tree().create_timer(1).timeout
		match choice:
			0:
				_lancelot.modify_data("prouesse", 10, false)
				await get_tree().create_timer(1).timeout
				_lancelot.modify_data("amour", 10, true)
			1:
				_lancelot.modify_data("amour", 100, false)
			_:
				push_error("Cannot understand answer ", choice)
		await get_tree().create_timer(2).timeout

		_dwarf.queue_free()
		_lancelot.global_position += Vector2(30, 0)
		_lancelot.change_sprites("dwarf")
		await get_tree().create_timer(1).timeout
		_lancelot.go_to_point(
			Vector2(
				_peasant_1.global_position.x,
				_lancelot.global_position.y
			)
		)
		await get_tree().create_timer(2).timeout
		_lancelot.start_interaction()
		_peasant_1.go_to("up", 70, true)
		await get_tree().create_timer(1).timeout
		_dialogue_box.start_dialogue_lines(
			"La paysanne", [
				"Honte au chevalier de la charrette !",
			]
		)
		_lancelot.modify_data("prouesse", 10, false)
		await _dialogue_box.dialogue_finished

		_lancelot.go_to_point(
			Vector2(
				_peasant_2.global_position.x,
				_lancelot.global_position.y
			)
		)
		await get_tree().create_timer(2).timeout
		_lancelot.start_interaction()
		_peasant_2.go_to("up", 20, true)
		await get_tree().create_timer(1).timeout

		_dialogue_box.start_dialogue_lines(
			"Le paysan", [
				"Un chevalier criminel !",
			]
		)
		_lancelot.modify_data("prouesse", 10, false)
		await _dialogue_box.dialogue_finished

		_lancelot.go_to_point(
			Vector2(
				_peasant_3.global_position.x,
				_lancelot.global_position.y
			)
		)
		await get_tree().create_timer(2.5).timeout
		_lancelot.start_interaction()
		_peasant_3.go_to("up", 20, true)
		await get_tree().create_timer(1).timeout
		_dialogue_box.start_dialogue_lines(
			"Le paysan", [
				"Maudit soit le chevalier de la charrette !",
			]
		)
		_lancelot.modify_data("prouesse", 10, false)
		await _dialogue_box.dialogue_finished
		
		_lancelot.go_to_point(
			_lancelot.global_position +
			Vector2(450, 0)
		)
		
		await get_tree().create_timer(3).timeout
		_gauvain.global_position = _lancelot.global_position - Vector2(350, 50)
		_gauvain.go_to("right", 300, true)

		_dialogue_box.start_dialogue_lines(
			"La Demoiselle", [
				"Chevaliers, soyez les bienvenus. Veuillez entrer.",
			]
		)
		await _dialogue_box.dialogue_finished
		SceneManager.change_scene("res://scenes/chateau_2/chateau_2.tscn")
