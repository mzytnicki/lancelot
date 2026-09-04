extends CanvasLayer
class_name BarsScreen



@onready var _bar_prouesse:   ProgressBar = $Panel/Margin/VBox/HBoxProuesse/ProgressBar
@onready var _bar_amour:      ProgressBar = $Panel/Margin/VBox/HBoxAmour/ProgressBar
@onready var _bar_courtoisie: ProgressBar = $Panel/Margin/VBox/HBoxCourtoisie/ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_bar_prouesse.value = 10
	_bar_amour.value = 10
	_bar_courtoisie.value = 10


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func set_value_to(type: String, to: int) -> void:
	var bar: ProgressBar
	match type:
		"prouesse":
			bar = _bar_prouesse
		"amour":
			bar = _bar_amour
		"courtoisie":
			bar = _bar_courtoisie
		_:
			push_error("Do not undestand type ", type)

	var tween = create_tween()
	tween.tween_property(bar, "value", to, 0.2)
