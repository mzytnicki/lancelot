extends CanvasLayer
## A 3-slot save/load selection dialog.

signal slot_selected(slot: int)

@onready var _buttons: Array[Button] = [
	$Panel/VBox/Slot1Button,
	$Panel/VBox/Slot2Button,
	$Panel/VBox/Slot3Button,
]
@onready var _cancel_btn: Button = $Panel/VBox/CancelButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(_buttons.size()):
		_buttons[i].pressed.connect(_on_slot_pressed.bind(i + 1))
	_cancel_btn.pressed.connect(func() -> void: slot_selected.emit(0))
	get_tree().paused = true
	refresh()
	_buttons[0].grab_focus()


func _on_slot_pressed(slot: int) -> void:
	get_tree().paused = false
	slot_selected.emit(slot)


func refresh() -> void:
	for i in range(_buttons.size()):
		var slot_num: int = i + 1
		var info: Dictionary = SaveManager.get_slot_info(slot_num)
		if info.is_empty():
			_buttons[i].text = "Slot " + str(slot_num) + ": Empty"
		else:
			var scene_label: String = info.get("scene_path", "").get_file().get_basename().capitalize()
			_buttons[i].text = "Slot " + str(slot_num) + ": " + scene_label
