extends Node2D
## Crystal Cavern dungeon scene.

@onready var _encounter_system: Node = $EncounterSystem


func _ready() -> void:
	GameManager.set_flag("entered_crystal_cavern")
	_encounter_system.encounter_triggered.connect(_on_encounter_triggered)


func _on_encounter_triggered(encounter: EncounterData) -> void:
	# Convert EnemyData to BattlerData for the battle system
	var enemy_battlers: Array[BattlerData] = []
	for ed in encounter.enemies:
		enemy_battlers.append(BattlerData.from_enemy(ed))

	# Build party (temporary, Module 21 adds a proper PartyManager)
	var hero := BattlerData.new()
	hero.character_data = load("res://data/characters/aiden.tres")
	hero.is_player_controlled = true

	# Must use Dictionary format, matches SceneManager.start_battle() from Module 14
	SceneManager.start_battle([hero], enemy_battlers)
