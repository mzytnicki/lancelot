extends Node2D

@onready var _guenievre: CharacterBody2D = $Guenievre
@onready var _meleagant: CharacterBody2D = $Meleagant


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_meleagant.face_direction("right")
	_guenievre.face_direction("right")




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
