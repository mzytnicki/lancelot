extends Node2D

# @onready var _bars_screen:  CanvasLayer = $BarsScreen

@onready var _dialogue_box: CanvasLayer = $DialogueBox

@onready var _lancelot:   CharacterBody2D = $YSortGroup/Lancelot
@onready var _peasant_1:  CharacterBody2D = $YSortGroup/Peasant_1
@onready var _peasant_2:  CharacterBody2D = $YSortGroup/Peasant_2
@onready var _peasant_3:  CharacterBody2D = $YSortGroup/Peasant_3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_peasant_1.play_animation("work_right", true)
	_peasant_2.play_animation("work_down", true)
	_peasant_3.play_animation("work_down", true)
	_lancelot.change_sprites("lancelot")

	_lancelot.start_interaction()
	_dialogue_box.start_dialogue_lines(
		"", [ "Utilisez les flèches pour déplacer le chevalier.", ]
	)
	await _dialogue_box.dialogue_finished
	_lancelot.end_interaction()


func _input(event: InputEvent) -> void:
	# Temporary: press B to start a test battle
	if event is InputEventKey and event.pressed and event.keycode == KEY_M:
		SceneManager.change_scene("res://scenes/chateau_2/chateau_2.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
