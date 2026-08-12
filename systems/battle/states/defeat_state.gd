extends BattleState
## Party wiped. Show game over screen.


func enter(_context: Dictionary = {}) -> void:
	print("DEFEAT")
	print("The party has fallen...")
	battle_manager.sync_party_to_character_data()
	battle_manager.battle_lost.emit()

	await get_tree().create_timer(2.0).timeout

	# Return to title screen (or last save point)
	# For now, just reload the main scene
	SceneManager.change_scene("res://scenes/willowbrook/willowbrook.tscn", "default")
