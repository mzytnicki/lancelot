# victory_state.gd
extends BattleState
## Battle won. Calculate and display rewards.


func enter(_context: Dictionary = {}) -> void:
	print("VICTORY")

	var total_xp: int = 0
	var total_gold: int = 0
	var dropped_items: Array[ItemData] = []

	# Calculate rewards from all enemies
	for enemy in battle_manager.enemies:
		if enemy.enemy_data:
			total_xp += enemy.enemy_data.xp_reward
			total_gold += enemy.enemy_data.gold_reward
			var r : float = randf()
			if enemy.enemy_data.drop_item and r < enemy.enemy_data.drop_chance:
				dropped_items.append(enemy.enemy_data.drop_item)

	# Distribute XP to party members
	var xp_per_member: int = total_xp / max(1, battle_manager.get_alive_party().size())
	for battler in battle_manager.get_alive_party():
		_apply_xp(battler, xp_per_member)

	# Sync battle HP/MP back to CharacterData for persistence
	battle_manager.sync_party_to_character_data()

	# Grant gold
	InventoryManager.add_gold(total_gold)
	print("Gained " + str(total_gold) + " gold!")

	# Grant dropped items
	for item in dropped_items:
		InventoryManager.add_item(item)
		print("Found: " + item.display_name + "!")

	battle_manager.battle_won.emit()

	# Wait for player to acknowledge
	await get_tree().create_timer(2.0).timeout
	# Return to overworld
	SceneManager.return_from_battle()


func _apply_xp(battler: BattlerData, xp: int) -> void:
	if not battler.character_data:
		return

	var char_data: CharacterData = battler.character_data
	print(char_data.display_name + " gained " + str(xp) + " XP!")
	for result in char_data.grant_xp(xp):
		var gains: Dictionary = result.gains
		print(char_data.display_name + " reached level " + str(result.level) + "!")
		print("  HP +" + str(gains.hp) + ", ATK +" + str(gains.attack) +
			  ", DEF +" + str(gains.defense))
