extends Node
## Tracks player movement and triggers random encounters in encounter zones.

signal encounter_triggered(encounter: EncounterData)

var _step_count: int = 0
var _threshold: int = 0
var _in_encounter_zone: bool = false
var _current_encounters: Array[EncounterData] = []
var _encounter_rate: float = 0.6  # 60% chance per threshold hit; tune this for your dungeon
var _last_player_position: Vector2 = Vector2.ZERO

const STEP_DISTANCE: float = 16.0  # One tile = one step


func _process(_delta: float) -> void:
	if not _in_encounter_zone:
		return

	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return

	var distance: float = player.global_position.distance_to(_last_player_position)
	if distance >= STEP_DISTANCE:
		_last_player_position = player.global_position
		_step_count += 1
		_check_encounter()


func _check_encounter() -> void:
	if _step_count >= _threshold:
		_step_count = 0
		_threshold = randi_range(8, 20)  # Next threshold in 8-20 steps

		var r : float = randf()
		if r < _encounter_rate and not _current_encounters.is_empty():
			var encounter: EncounterData = _pick_weighted_encounter()
			if encounter:
				encounter_triggered.emit(encounter)


func _pick_weighted_encounter() -> EncounterData:
	if _current_encounters.is_empty():
		push_warning("EncounterSystem: no encounters configured.")
		return null

	var total_weight: float = 0.0
	for enc in _current_encounters:
		total_weight += max(0.0, enc.weight)

	if total_weight <= 0.0:
		push_warning("EncounterSystem: encounter weights must be greater than 0.")
		return null

	var roll: float = randf() * total_weight
	var cumulative: float = 0.0
	for enc in _current_encounters:
		cumulative += max(0.0, enc.weight)
		if roll <= cumulative:
			return enc

	return null


func enter_zone(encounters: Array[EncounterData], rate: float) -> void:
	_in_encounter_zone = true
	_current_encounters = encounters
	_encounter_rate = rate
	_threshold = randi_range(10, 25)
	_step_count = 0
	var player := get_tree().get_first_node_in_group("player")
	if player:
		_last_player_position = player.global_position


func exit_zone() -> void:
	_in_encounter_zone = false
	_current_encounters.clear()
