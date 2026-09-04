extends PanelContainer
## Persistent volume settings panel. Press Escape to close.

const SETTINGS_PATH := "user://settings.cfg"
const SETTINGS_SECTION := "audio"
const DEFAULT_MUSIC_VOLUME := 0.8
const DEFAULT_SFX_VOLUME := 0.8

@onready var _music_slider: HSlider = $VBox/MusicSlider
@onready var _sfx_slider: HSlider = $VBox/SFXSlider


func _ready() -> void:
	_music_slider.min_value = 0.0
	_music_slider.max_value = 1.0
	_music_slider.step = 0.05

	_sfx_slider.min_value = 0.0
	_sfx_slider.max_value = 1.0
	_sfx_slider.step = 0.05

	var settings := _load_settings()
	var music_volume: float = float(settings.get("music_volume", DEFAULT_MUSIC_VOLUME))
	var sfx_volume: float = float(settings.get("sfx_volume", DEFAULT_SFX_VOLUME))
	_music_slider.value = music_volume
	_sfx_slider.value = sfx_volume
	_apply_bus_volume("Music", music_volume)
	_apply_bus_volume("SFX", sfx_volume)

	_music_slider.value_changed.connect(_on_music_volume_changed)
	_sfx_slider.value_changed.connect(_on_sfx_volume_changed)


func _on_music_volume_changed(value: float) -> void:
	_apply_bus_volume("Music", value)
	_save_settings()


func _on_sfx_volume_changed(value: float) -> void:
	_apply_bus_volume("SFX", value)
	_save_settings()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		queue_free()
		get_viewport().set_input_as_handled()


func _apply_bus_volume(bus_name: String, value: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		return
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))


func _load_settings() -> Dictionary:
	var config := ConfigFile.new()
	var error := config.load(SETTINGS_PATH)
	if error != OK:
		return {}
	return {
		music_volume = config.get_value(
			SETTINGS_SECTION, "music_volume", DEFAULT_MUSIC_VOLUME,
		),
		sfx_volume = config.get_value(
			SETTINGS_SECTION, "sfx_volume", DEFAULT_SFX_VOLUME,
		),
	}


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value(SETTINGS_SECTION, "music_volume", _music_slider.value)
	config.set_value(SETTINGS_SECTION, "sfx_volume", _sfx_slider.value)
	var error := config.save(SETTINGS_PATH)
	if error != OK:
		push_warning("Failed to save audio settings: " + error_string(error))
