extends Node2D

@onready var _door: AnimatedSprite2D = $Door


func open() -> void:
	_door.play("open")
