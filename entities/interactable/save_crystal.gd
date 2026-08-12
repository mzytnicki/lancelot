extends StaticBody2D
## A save crystal. Lets the player save their game.

var _player_in_range: bool = false

@onready var _prompt: Label = $InteractionPrompt
@onready var _zone: Area2D = $InteractionZone


func _ready() -> void:
	_zone.body_entered.connect(_on_body_entered)
	_zone.body_exited.connect(_on_body_exited)
	_prompt.visible = false
	# add_to_group("save_points")  # Nothing reads this group yet; left for a future query helper


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range:
		return
	if event.is_action_pressed("interact"):
		_activate()
		get_viewport().set_input_as_handled()


func _activate() -> void:
	# Module 22 will add actual saving here
	print("Your progress has been saved!")
	# Optional: heal the party at save points (common JRPG pattern)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		_prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_prompt.visible = false
