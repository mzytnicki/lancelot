extends BattleState
## Checks if the battle is over after an action.


func enter(_context: Dictionary = {}) -> void:
	if not battle_manager.is_enemy_alive():
		battle_manager.transition_to_state("Victory")
	elif not battle_manager.is_party_alive():
		battle_manager.transition_to_state("Defeat")
	else:
		# More turns to process, go back to TurnStart
		# The TurnStart state will get the next battler from the queue
		_process_next_in_queue()


func _process_next_in_queue() -> void:
	var battler : BattlerData = battle_manager.get_next_battler()

	if battler == null:
		# Round over, start a new round
		battle_manager.transition_to_state("TurnStart")
		return

	battle_manager.current_battler = battler
	battler.defense_boost = 0
	battle_manager.turn_started.emit(battler)

	if battler.is_player_controlled:
		battle_manager.transition_to_state("PlayerChoice", {battler = battler})
	else:
		battle_manager.transition_to_state("ActionExecute", {
			battler = battler,
			action = "enemy_turn",
		})
