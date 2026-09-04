extends CanvasLayer
## The in-game pause menu.

var _is_open: bool = false

@onready var _background: ColorRect = $Background
@onready var _resume_btn: Button = $Background/Panel/VBox/ResumeButton
@onready var _quit_btn: Button = $Background/Panel/VBox/QuitButton


func _ready() -> void:
	_background.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	_resume_btn.pressed.connect(close)
	_quit_btn.pressed.connect(_quit_to_title)
	$Background/Panel/VBox/InventoryButton.pressed.connect(_open_inventory)
	$Background/Panel/VBox/EquipmentButton.pressed.connect(_open_equipment)
	$Background/Panel/VBox/QuestLogButton.pressed.connect(_open_quest_log)
	$Background/Panel/VBox/SettingsButton.pressed.connect(_open_settings)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if not _can_pause_current_scene() and not _is_open:
		return

	if _is_open:
		close()
	else:
		open()
	get_viewport().set_input_as_handled()


func open() -> void:
	if not _can_pause_current_scene():
		return
	_is_open = true
	_background.visible = true
	get_tree().paused = true
	_resume_btn.grab_focus()


func close() -> void:
	_is_open = false
	_background.visible = false
	get_tree().paused = false


func _can_pause_current_scene() -> bool:
	var current_scene := get_tree().current_scene
	return current_scene and current_scene.is_in_group("pause_allowed")


func _hide_for_submenu() -> void:
	_is_open = false
	_background.visible = false


func _open_inventory() -> void:
	# Use Module 12's public API instead of toggling visibility directly.
	var inv := get_tree().get_first_node_in_group("inventory_screens")
	if inv and inv.has_method("open_from_pause"):
		_hide_for_submenu()
		inv.call("open_from_pause")


func _open_equipment() -> void:
	# Use Module 21's public API instead of toggling visibility directly.
	var equipment := get_tree().get_first_node_in_group("equipment_panels")
	if equipment and equipment.has_method("open_from_pause"):
		_hide_for_submenu()
		equipment.call("open_from_pause")


func _open_quest_log() -> void:
	# Use Module 20's public API instead of toggling visibility directly.
	var log_panel := get_tree().get_first_node_in_group("quest_logs")
	if log_panel and log_panel.has_method("open_from_pause"):
		_hide_for_submenu()
		log_panel.call("open_from_pause")


func _open_settings() -> void:
	# Show the settings panel from Module 24
	var settings_scene := preload("res://ui/settings/settings_panel.tscn")
	var panel: PanelContainer = settings_scene.instantiate()

	# Same centering and focus pattern as the title screen's settings.
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	center.add_child(panel)

	panel.get_node("VBox/MusicSlider").grab_focus.call_deferred()


func _quit_to_title() -> void:
	close()
	SceneManager.change_scene("res://ui/title_screen/title_screen.tscn")
