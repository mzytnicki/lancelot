extends CanvasLayer
class_name BarsScreen



@onready var _bar_prouesse:   ProgressBar = $Panel/Margin/VBox/HBoxProuesse/ProgressBar
@onready var _bar_amour:      ProgressBar = $Panel/Margin/VBox/HBoxAmour/ProgressBar
@onready var _bar_courtoisie: ProgressBar = $Panel/Margin/VBox/HBoxCourtoisie/ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var char_data: CharacterData = PartyManager.get_member_by_id("lancelot")
	_bar_prouesse.value   = char_data.current_prouesse
	_bar_amour.value      = char_data.current_amour
	_bar_courtoisie.value = char_data.current_courtoisie


func set_value(type: String, to: int, relative: bool = false) -> void:
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
	if relative:
		to = int(bar.value) + to
	tween.tween_property(bar, "value", to, 0.2)
