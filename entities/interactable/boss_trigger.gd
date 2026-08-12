extends Area2D
## Triggers the boss fight with a pre-battle cutscene.

@export var boss_data: EnemyData
var _triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not _triggered:
		_triggered = true
		_start_boss_sequence()


func _start_boss_sequence() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_disabled"):
		player.set_disabled(true)

	# Pre-boss dialogue
	var line := DialogueLine.new()
	line.speaker_name = "Crystal Guardian"
	line.text = "You dare disturb the crystals? Prepare yourself!"

	var dialogue_box = get_tree().current_scene.get_node_or_null("DialogueBox")
	if dialogue_box:
		var lines: Array[DialogueLine] = [line]
		#dialogue_box.start_dialogue([line])
		dialogue_box.start_dialogue(lines)
		await dialogue_box.dialogue_finished

	# Start the boss battle
	_start_boss_battle()


func _start_boss_battle() -> void:
	if boss_data == null:
		push_error("BossTrigger: boss_data is not assigned. Drag a crystal_guardian.tres into the Boss Data field.")
		return

	var hero := BattlerData.new()
	hero.character_data = load("res://data/characters/aiden.tres")
	hero.is_player_controlled = true

	var boss := BattlerData.from_enemy(boss_data)

	SceneManager.start_battle([hero], [boss])
