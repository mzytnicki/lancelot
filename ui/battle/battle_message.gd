extends PanelContainer

@onready var _label: Label = $MarginContainer/Label

func set_message(text: String) -> void:
	visible = true
	_label.text = text
	await get_tree().create_timer(2).timeout
	visible = false
