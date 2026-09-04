extends Area2D

@onready var _dialogue_box: CanvasLayer = $"../DialogueBox"

@onready var _lancelot:  CharacterBody2D = $"../YSortGroup/Lancelot"
@onready var _dame_1:  CharacterBody2D = $"../YSortGroup/Dame_1"
@onready var _before_bed:  Marker2D = $"../BeforeBed"
@onready var _between_beds:  Marker2D = $"../BetweenBeds"
@onready var _big_bed:  Marker2D = $"../BigBed"
@onready var _small_bed:  Marker2D = $"../SmallBed"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
	if body.is_in_group("player"):
		_lancelot.start_interaction()
		await get_tree().create_timer(1).timeout
		_lancelot.go_to_point(_before_bed.global_position)
		await _lancelot.target_reached
		_lancelot.start_interaction()
		_dialogue_box.start_dialogue_lines(
			"Le Chevalier", [
				"Quel est ce lit, plus beau que les autres ? Il est digne d'un roi.",
			]
		)
		await _dialogue_box.dialogue_finished
		_dame_1.go_to("up", 250, true)
		await get_tree().create_timer(1.5).timeout
		_lancelot.face_direction("down")
		_lancelot.start_interaction()
		var lines := _make_lines(
			"La Demoiselle", [
				"Il est interdit à tout homme qui n'aurait pas mérité de s'y étendre.",
				"Il ne peut être occupé que par un chevalier valereux.",
				"Vous, qui êtes monté dans la charrette, vous pouvez moins que quiconque y prétendre."
			]
		)
		lines[2].choices = ["Dame, je respecte votre décision et choisis un lit plus humble.",
			"C'est ce qu'on verra !"]
		_dialogue_box.start_dialogue(lines)
		var choice: int = await _dialogue_box.choice_made
		var marker: Marker2D
		var marker_string: String
		match choice:
			0:
				_lancelot.modify_data("courtoisie", 10, true)
				await get_tree().create_timer(1).timeout
				_lancelot.modify_data("prouesse", 10, false)
				marker = _small_bed
				marker_string = "SmallBed"
			1:
				_lancelot.modify_data("courtoisie", 10, false)
				marker = _big_bed
				marker_string = "BigBed"
			_:
				push_error("Cannot understand answer ", choice)
		await get_tree().create_timer(2).timeout
		_lancelot.go_to_point(_between_beds.global_position)
		await _lancelot.target_reached
		_lancelot.go_to_point(marker.global_position)
		await _lancelot.target_reached
		_lancelot.start_interaction()
		await get_tree().create_timer(0.5).timeout
		_lancelot.face_direction("down")
		_lancelot.start_interaction()
		SceneManager.change_scene("res://scenes/chateau_2/chateau_2.tscn", marker_string)
