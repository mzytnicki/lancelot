extends Node2D

@onready var _lancelot: CharacterBody2D  = $Lancelot


func _ready() -> void:
	await get_tree().create_timer(2.0).timeout
	_lancelot.die_animation()
	await get_tree().create_timer(6.0).timeout

	# Show the Game Over screen instead of reloading Willowbrook
	SceneManager.change_scene("res://ui/game_over/game_over.tscn")
