extends BattleState
## Party wiped. Show Game Over screen.


func enter(_context: Dictionary = {}) -> void:
	battle_manager.battle_lost.emit()

	await get_tree().create_timer(2.0).timeout

	# Show the Game Over screen instead of reloading Willowbrook
	SceneManager.change_scene("res://ui/game_over/game_over.tscn")
