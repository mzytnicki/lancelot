extends Node2D

@onready var _pendant_chest: StaticBody2D = $YSortGroup/PendantChest


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.set_flag("reached_whisperwood")
	_pendant_chest.opened.connect(_on_pendant_chest_opened)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pendant_chest_opened() -> void:
	GameManager.set_flag("pendant_found")
