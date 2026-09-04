extends Control
## The game's title screen.

@onready var _new_game_btn: Button = $MenuContainer/NewGameButton
@onready var _continue_btn: Button = $MenuContainer/ContinueButton
@onready var _settings_btn: Button = $MenuContainer/SettingsButton


func _ready() -> void:
	MusicManager.play_music("res://audio/music/title_theme.ogg")

	_new_game_btn.pressed.connect(_on_new_game)
	_continue_btn.pressed.connect(_on_continue)
	_settings_btn.pressed.connect(_on_settings)

	# Disable Continue if no saves exist
	_continue_btn.disabled = not _any_saves_exist()

	_new_game_btn.grab_focus()


func _on_new_game() -> void:
	_initialize_fresh_state()
	SceneManager.change_scene("res://scenes/willowbrook/willowbrook.tscn")


func _on_continue() -> void:
	# Show save slot dialog from Module 22
	var dialog_scene := preload("res://ui/save_slot_dialog/save_slot_dialog.tscn")
	var dialog: Control = dialog_scene.instantiate()
	add_child(dialog)
	var slot: int = await dialog.slot_selected
	dialog.queue_free()
	if slot == 0:
		return
	SaveManager.load_game(slot)


func _on_settings() -> void:
	# Show the persistent volume settings panel from Module 24
	var settings_scene := preload("res://ui/settings/settings_panel.tscn")
	var panel: PanelContainer = settings_scene.instantiate()

	# A CenterContainer fills the screen and keeps the panel in its center.
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	center.add_child(panel)

	# Focus the first interactive control so keyboard and gamepad work.
	# PanelContainer is a container, not focusable, so we focus the slider.
	# call_deferred makes grab_focus reliable for a freshly added node.
	panel.get_node("VBox/MusicSlider").grab_focus.call_deferred()


func _initialize_fresh_state() -> void:
	# Reset all autoloads to starting state
	GameManager.from_save_data({})

	# Reset inventory
	InventoryManager.from_save_data({gold = 100, items = []})
	var potion: ItemData = load("res://data/items/potion.tres")
	if potion:
		InventoryManager.add_item(potion, 3)

	# Reset party to just the hero
	PartyManager.from_save_data({members = []})
	var aiden := ResourceLoader.load(
		"res://data/characters/aiden.tres", "", ResourceLoader.CACHE_MODE_IGNORE,
	) as CharacterData
	if aiden:
		aiden.current_hp = aiden.max_hp
		aiden.current_mp = aiden.max_mp
		aiden.current_xp = 0
		PartyManager.add_member(aiden)

	# Reset quests
	QuestManager.from_save_data({active = [], completed = [], turned_in = []})


func _any_saves_exist() -> bool:
	for i in range(1, SaveManager.MAX_SLOTS + 1):
		if SaveManager.slot_exists(i):
			return true
	return false
