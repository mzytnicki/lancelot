extends Node2D

@onready var _guenievre: CharacterBody2D = $Guenievre
@onready var _meleagant: CharacterBody2D = $Meleagant


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_meleagant.face_direction("right")
	_guenievre.face_direction("right")
	await get_tree().create_timer(0.5).timeout
	_meleagant.go_to("right", 300, false)
	await _guenievre.go_to("right", 50, true)
	await get_tree().create_timer(1).timeout
	await _guenievre.go_to("right", 50, true)
	await get_tree().create_timer(1).timeout
	await _guenievre.go_to("right", 50, true)
	await get_tree().create_timer(1).timeout
	await _guenievre.go_to("right", 50, true)
	await get_tree().create_timer(1).timeout
	await _meleagant.go_to("left", 100, true)
	await get_tree().create_timer(1).timeout
	_meleagant.go_to("right", 600, false)
	await _guenievre.go_to("right", 600, true)
	SceneManager.change_scene("res://scenes/chateau_2/chateau_2.tscn", "BeforeBed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
