extends Node2D


# @onready var _bars_screen:  CanvasLayer = $BarsScreen

@onready var _dialogue_box: CanvasLayer = $DialogueBox

@onready var _lancelot:  CharacterBody2D = $YSortGroup/Lancelot
@onready var _lancelot_cheval:  CharacterBody2D = $YSortGroup/Lancelot_cheval
@onready var _lancelot_charette:  CharacterBody2D = $YSortGroup/Lancelot_charrette
@onready var _peasant_1:  CharacterBody2D = $YSortGroup/Peasant_1
@onready var _peasant_2:  CharacterBody2D = $YSortGroup/Peasant_2
@onready var _peasant_3:  CharacterBody2D = $YSortGroup/Peasant_3



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_lancelot_cheval.set_disabled(true)
	_lancelot_charette.set_disabled(true)
	_peasant_1.play_animation("work_right", true)
	_peasant_2.play_animation("work_down", true)
	_peasant_3.play_animation("work_down", true)


	_lancelot.start_interaction()
	_dialogue_box.start_dialogue_lines(
		"", [ "Utilisez les flèches pour déplacer le chevalier.", ]
	)
	await _dialogue_box.dialogue_finished
	_lancelot.end_interaction()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
