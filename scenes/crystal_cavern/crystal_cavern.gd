extends Node2D
## Crystal Cavern dungeon scene.

@onready var _encounter_system: Node = $EncounterSystem


func _ready() -> void:
	MusicManager.play_music("res://audio/music/dungeon_theme.mp3")
	GameManager.set_flag("entered_crystal_cavern")
	_encounter_system.encounter_triggered.connect(_on_encounter_triggered)


func _on_encounter_triggered(encounter: EncounterData) -> void:
	# Convert EnemyData to BattlerData for the battle system
	var enemy_battlers: Array[BattlerData] = []
	for ed in encounter.enemies:
		enemy_battlers.append(BattlerData.from_enemy(ed))

	# Build party BattlerData from PartyManager
	var party_battlers: Array[BattlerData] = []
	for char_data in PartyManager.get_members():
		var battler := BattlerData.new()
		battler.character_data = char_data
		battler.is_player_controlled = true
		party_battlers.append(battler)

	# Use the full party instead of just [hero]
	SceneManager.start_battle(party_battlers, enemy_battlers)
