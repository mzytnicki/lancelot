extends BattleState
## Builds the turn queue and starts processing turns.


func enter(_context: Dictionary = {}) -> void:
	battle_manager.build_turn_queue()
	_process_next_turn()


func _process_next_turn() -> void:
	var battler : BattlerData = battle_manager.get_next_battler()

	if battler == null:
		# All turns exhausted, start a new round
		battle_manager.transition_to_state("TurnStart")
		return

	battle_manager.current_battler = battler

	# Reset temporary buffs at the start of each turn
	battler.defense_boost = 0

	battle_manager.turn_started.emit(battler)

	if battler.is_player_controlled:
		battle_manager.transition_to_state("PlayerChoice", {battler = battler})
	else:
		battle_manager.transition_to_state("ActionExecute", {
			battler = battler,
			action = "enemy_turn",
		})
