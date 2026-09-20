extends Node2D


@onready var _lancelot:     CharacterBody2D = $YSortGroup/Lancelot
@onready var _gauvain:      CharacterBody2D = $YSortGroup/Gauvain
@onready var _dame:         CharacterBody2D = $YSortGroup/Dame
@onready var _dame_area:    Area2D          = $DameArea
@onready var _dialogue_box: CanvasLayer     = $DialogueBox




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_lancelot.change_sprites("horse")
	_lancelot.face_direction("right")
	_dame.play_animation("idle_left", true)
	_dame_area.body_entered.connect(_on_dame_meet)


func _on_dame_meet(body: Node2D) -> void:
	if body.is_in_group("player"):
		_lancelot.start_interaction()
		await get_tree().create_timer(1).timeout
		_lancelot.go_to_point($LancelotPlace.global_position)
		await get_tree().create_timer(1).timeout
		_lancelot.start_interaction()
		_gauvain.global_position = $GauvainPlace.global_position - Vector2(500, 0)
		_gauvain.visible = true
		await _gauvain.go_to("right", 500, true)
		_dialogue_box.start_dialogue(DialogueLine.make_lines(
			"Le Chevalier", [
				"Demoiselle, avez-vous vu passer un géant emmenant la reine ?",
			]
		))
		await _dialogue_box.dialogue_finished
		var lines := DialogueLine.make_lines(
			"La Demoiselle", [
				"Je peux vous donner le nom de celui qui l'emmène, mais sachez que vous connaîtrez de grandes souffrances avant d'arriver dans son pays.",
			]
		)
		lines[0].choices = ["Je vous en prie, dites-le moi !",
			"Je vous promets de faire tout ce que vous voudrez si vous me le dites."]
		_dialogue_box.start_dialogue(lines)
		var choice: int = await _dialogue_box.choice_made
		match choice:
			0:
				_lancelot.modify_data("courtoisie", 5, true)
				await get_tree().create_timer(1).timeout
			1:
				_lancelot.modify_data("courtoisie", 5, true)
				await get_tree().create_timer(1).timeout
				_lancelot.modify_data("amour", 10, true)
				await get_tree().create_timer(1).timeout
		_dialogue_box.start_dialogue(DialogueLine.make_lines(
			"La Demoiselle", [
				"Sachez que la reine a été enlevée par Méléagant, le fils du roi de Gorre.",
				"Il l'a conduite dans son royaume, dont nul ne revient.",
			]
		))
		await _dialogue_box.dialogue_finished
		_dialogue_box.start_dialogue(DialogueLine.make_lines(
			"Le Chevalier", [
				"Où se trouve ce royaume ?",
			]
		))
		await _dialogue_box.dialogue_finished
		_dialogue_box.start_dialogue(DialogueLine.make_lines(
			"La Demoiselle", [
				"Deux chemins y mènent, égalemen très périlleux :",
				"le Pont sous les Eaux, et le Pont de l'Épée, encore plus dangereux que le premier.",
			]
		))
		await _dialogue_box.dialogue_finished
		lines = DialogueLine.make_lines(
			"Gauvain", [
				"Choisissons chacun un chemin différent.",
				"Ainsi, nous aurons plus de chances que l'un de nous parvienne vite auprès de la reine.",
			]
		)
		lines[1].choices = ["Je choisis le deuxième chemin.",
			"Messire Gauvain, choisissez le chemin que vous préférez."]
		_dialogue_box.start_dialogue(lines)
		choice = await _dialogue_box.choice_made
		if choice == 1:
			_lancelot.modify_data("courtoisie", 20, true)
			await get_tree().create_timer(1).timeout
			_dialogue_box.start_dialogue(DialogueLine.make_lines(
				"Gauvain", [
					"Merci de votre courtoisie. J'irai au Pont sous les Eaux.",
				]
			))
			await _dialogue_box.dialogue_finished
		_gauvain.go_to("down", 300, false)
		_lancelot.go_to_point($LancelotExit.global_position)
