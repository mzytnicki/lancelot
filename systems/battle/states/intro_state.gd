extends BattleState
## Brief intro animation before combat begins.


func enter(_context: Dictionary = {}) -> void:
	# In a full game, play a swipe animation or battle start effect
	# For now, just wait briefly and proceed
	await get_tree().create_timer(0.5).timeout
	battle_manager.transition_to_state("TurnStart")
