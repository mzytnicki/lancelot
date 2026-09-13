# victory_state.gd
extends BattleState
## Battle won. Calculate and display rewards.


func enter(_context: Dictionary = {}) -> void:
	battle_manager.set_message("Victoire !")
	
	# Check if this was the final boss fight
	var is_boss_fight: bool = false
	for enemy in battle_manager.enemies:
		if enemy.enemy_data and enemy.enemy_data.id.is_empty():
			push_warning("EnemyData missing id: " + enemy.enemy_data.resource_path)
		if enemy.enemy_data and enemy.enemy_data.id == "crystal_guardian":
			is_boss_fight = true
			break

	if is_boss_fight:
		battle_manager.sync_party_to_character_data()
		GameManager.set_flag("boss_defeated")
		GameManager.set_flag("world.crystal_cavern.crystal_guardian.defeated")
		await get_tree().create_timer(2.0).timeout
		SceneManager.change_scene("res://ui/ending/ending.tscn")
		return  # Skip normal victory flow

	var total_xp: int = 0
	var total_prouesse: int = 0
	#var total_gold: int = 0
	var dropped_items: Array[ItemData] = []

	# Calculate rewards from all enemies
	for enemy in battle_manager.enemies:
		if enemy.enemy_data:
			total_xp += enemy.enemy_data.xp_reward
			total_prouesse += enemy.enemy_data.prouesse_reward
			#total_gold += enemy.enemy_data.gold_reward
			var r : float = randf()
			if enemy.enemy_data.drop_item and r < enemy.enemy_data.drop_chance:
				dropped_items.append(enemy.enemy_data.drop_item)

	# Distribute XP to party members
	#var xp_per_member: int = total_xp / max(1, battle_manager.get_alive_party().size())
	var prouesse_per_member: int = total_prouesse / max(1, battle_manager.get_alive_party().size())
	#for battler in battle_manager.get_alive_party():
	#	_apply_xp(battler, xp_per_member)
	#	_apply_prouesse(battler, prouesse_per_member)

	# Sync battle HP/MP back to CharacterData for persistence
	#battle_manager.sync_party_to_character_data()
	
	# Reset prouesse to previous value, and add new as XP
	await battle_manager.add_prouesse(prouesse_per_member)


	# Grant gold
	#f total_gold > 0:
	#	InventoryManager.add_gold(total_gold)
	#	print("Gained " + str(total_gold) + " gold!")

	# Grant dropped items
	#for item in dropped_items:
	#	InventoryManager.add_item(item)
	#	print("Found: " + item.display_name + "!")

	battle_manager.battle_won.emit()

	# Wait for player to acknowledge
	await get_tree().create_timer(2.0).timeout
	# Return to overworld
	SceneManager.return_from_battle()


#func _apply_xp(battler: BattlerData, xp: int) -> void:
#	if not battler.character_data:
#		return
#
#	var char_data: CharacterData = battler.character_data
#	print(char_data.display_name + " gained " + str(xp) + " XP!")
#	for result in char_data.grant_xp(xp):
#		var gains: Dictionary = result.gains
#		print(char_data.display_name + " reached level " + str(result.level) + "!")
#		print("  HP +" + str(gains.hp) + ", ATK +" + str(gains.attack) +
#			  ", DEF +" + str(gains.defense))


func _apply_prouesse(battler: BattlerData, prouesse: int) -> void:
	if not battler.character_data:
		return

	var char_data: CharacterData = battler.character_data
	char_data.grant_prouesse(prouesse)
