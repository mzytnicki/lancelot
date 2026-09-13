extends Node2D
## Orchestrates battle flow. Attached to the Battle scene root (Node2D).

signal battle_started(party: Array[BattlerData], enemies: Array[BattlerData])
signal turn_started(battler: BattlerData)
signal action_executed(attacker: BattlerData, target: BattlerData, damage: int)
signal battle_won
signal battle_lost

var party: Array[BattlerData] = []
var enemies: Array[BattlerData] = []
var turn_queue: Array[BattlerData] = []
var current_battler: BattlerData

@onready var _state_machine: BattleStateMachine = $BattleStateMachine
@onready var _party_positions: Node2D = $PartyPositions
@onready var _enemy_positions: Node2D = $EnemyPositions
@onready var _bar_screen: BarsScreen = $BarsScreen
@onready var _message_box: PanelContainer = $BattleUI/BattleMessage



const BattlerSpriteScene := preload("res://entities/battle/battler_sprite.tscn")


func _ready() -> void:
	# Pass a reference to this manager into every state
	for state in _state_machine.states.values():
		state.battle_manager = self
	# Don't start the state machine here. Wait for initialize_battle()
	# to populate party and enemies first.
	#
	# NOTE: Child nodes' _ready() runs BEFORE the parent's _ready().
	# That means each state's _ready() has already fired by this point,
	# so battle_manager was null during their _ready(). Never access
	# battle_manager in a state's _ready(). Use enter() instead.
	action_executed.connect(_on_hit)


func initialize_battle(party_data: Array[BattlerData], enemy_data: Array[BattlerData]) -> void:
	party = party_data
	enemies = enemy_data

	# Initialize runtime stats
	for battler in party:
		battler.initialize_from_character()
	for battler in enemies:
		battler.initialize_from_character()

	# Spawn sprites
	_spawn_battler_sprites(party, _party_positions)
	_spawn_battler_sprites(enemies, _enemy_positions)

	battle_started.emit(party, enemies)

	# NOW start the state machine, data is ready
	_state_machine.start("Intro")


func transition_to_state(state_name: String, context: Dictionary = {}) -> void:
	_state_machine.transition_to(state_name, context)


func _spawn_battler_sprites(battlers: Array[BattlerData], positions: Node2D) -> void:
	var slots := positions.get_children()
	for i in battlers.size():
		if i >= slots.size():
			break
		var sprite_node: Node2D = BattlerSpriteScene.instantiate()
		slots[i].add_child(sprite_node)
		sprite_node.setup(battlers[i])


func build_turn_queue() -> void:
	turn_queue.clear()

	# Gather all alive combatants
	var all_battlers: Array[BattlerData] = []
	for b in party:
		if b.is_alive():
			all_battlers.append(b)
	for b in enemies:
		if b.is_alive():
			all_battlers.append(b)

	# Sort by speed (highest first). sort_custom() takes an inline function
	# (also called a lambda): func(a, b) -> bool returns true if a should
	# come before b. GDScript supports these for one-off comparisons.
	# sort_custom() is not stable; equal-speed ties may resolve in any order.
	all_battlers.sort_custom(func(a: BattlerData, b: BattlerData) -> bool:
		return a.current_speed > b.current_speed
	)

	turn_queue = all_battlers


func get_next_battler() -> BattlerData:
	while not turn_queue.is_empty():
		var battler: BattlerData = turn_queue.pop_front()
		if battler.is_alive():
			return battler
	return null


func is_party_alive() -> bool:
	return party.any(func(b: BattlerData) -> bool: return b.is_alive())


func is_enemy_alive() -> bool:
	return enemies.any(func(b: BattlerData) -> bool: return b.is_alive())


func get_alive_enemies() -> Array[BattlerData]:
	return enemies.filter(func(b: BattlerData) -> bool: return b.is_alive())


func get_alive_party() -> Array[BattlerData]:
	return party.filter(func(b: BattlerData) -> bool: return b.is_alive())

	
func sync_party_to_character_data() -> void:
	for battler in party:
		if battler.character_data:
			battler.character_data.current_hp         = battler.current_hp
			battler.character_data.current_mp         = battler.current_mp
			battler.character_data.current_amour      = battler.current_amour
			battler.character_data.current_courtoisie = battler.current_courtoisie
			battler.character_data.current_prouesse   = battler.current_prouesse


func _on_hit(_attacker: BattlerData, target: BattlerData, damage: int) -> void:
	if target.character_data.id == "lancelot":
		update_prouesse(-damage, true)


func update_prouesse(value: int, relative: bool):
	_bar_screen.set_value("prouesse", value, relative)


func set_message(message: String) -> void:
	_message_box.set_message(message)
	

func add_prouesse(value: int):
	var lancelot: CharacterData = PartyManager.get_member_by_id("lancelot")
	update_prouesse(lancelot.current_prouesse, false)
	await get_tree().create_timer(1.0).timeout
	update_prouesse(value, true)
	_spawn_prouesse(value)
	set_message("Gagné " + str(value) + " prouesse !")
	await get_tree().create_timer(1.0).timeout
	lancelot.max_prouesse += value
	lancelot.current_prouesse += value


func _find_battler_sprite() -> Node2D:
	for sprite in get_tree().get_nodes_in_group("battler_sprites"):
		if sprite.battler_data.character_data.id == "lancelot":
			return sprite
	return null


func _spawn_prouesse(amount: int) -> void:
	var sprite_node := _find_battler_sprite()
	if not sprite_node:
		return

	var label := Label.new()
	label.text = str(amount)
	label.add_theme_color_override("font_color", Color.GREEN)
	label.z_index = 100
	# Add the label as a child of the sprite (Node2D), not the scene root.
	# This ensures the label uses Node2D coordinates, matching the sprite's position.
	sprite_node.add_child(label)
	label.position = Vector2(0, -20)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", -50.0, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.chain().tween_callback(label.queue_free)
