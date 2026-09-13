extends Resource
class_name BattlerData
## Runtime data for a combatant in battle.

@export var character_data: CharacterData
@export var is_player_controlled: bool = true

# Runtime state (not saved to .tres, set during battle)
var current_hp: int = 0
var current_courtoisie: int = 0
var current_amour: int = 0
var current_prouesse: int = 0
var current_mp: int = 0
var current_attack: int = 0
var current_defense: int = 0
var current_speed: int = 0
var defense_boost: int = 0  # Temporary boost from Defend action
var enemy_data: EnemyData = null


func initialize_from_character() -> void:
	if not character_data:
		return
	# Use current_hp/current_mp if set (carries over between battles)
	# Fall back to max values for the first battle or after a full heal
	current_hp         = character_data.current_hp         if character_data.current_hp > 0         else character_data.max_hp
	current_mp         = character_data.current_mp         if character_data.current_mp > 0         else character_data.max_mp
	current_courtoisie = character_data.current_courtoisie if character_data.current_courtoisie > 0 else character_data.max_courtoisie
	current_amour      = character_data.current_amour      if character_data.current_amour > 0      else character_data.max_amour
	current_prouesse   = character_data.current_prouesse   if character_data.current_prouesse > 0   else character_data.max_prouesse
	current_attack     = character_data.get_effective_attack()
	current_defense    = character_data.get_effective_defense()
	current_speed      = character_data.get_effective_speed()


func get_effective_defense() -> int:
	return current_defense + defense_boost


func is_alive() -> bool:
	return current_prouesse > 0


func take_damage(amount: int) -> int:
	var actual_damage: int = max(1, amount)
	#current_hp = max(0, current_hp - actual_damage)
	current_prouesse = max(0, current_prouesse - actual_damage)
	return actual_damage


func heal(amount: int) -> int:
	var old_prouesse := current_prouesse
	#current_hp = min(current_hp + amount, character_data.max_hp)
	current_prouesse = min(current_prouesse + amount, character_data.max_prouesse)
	return current_prouesse - old_prouesse  # Actual amount healed


static func from_enemy(enemy: EnemyData) -> BattlerData:
	var battler := BattlerData.new()
	var char_data := CharacterData.new()
	char_data.display_name = enemy.display_name
	char_data.animation = enemy.animation if enemy.animation else null
	char_data.portrait = enemy.sprite if enemy.sprite else preload("res://icon.svg")
	char_data.max_hp = enemy.max_hp
	char_data.max_mp = enemy.max_mp
	char_data.max_prouesse = enemy.max_prouesse
	char_data.attack = enemy.attack
	char_data.defense = enemy.defense
	char_data.speed = enemy.speed
	battler.character_data = char_data
	battler.is_player_controlled = false
	battler.enemy_data = enemy
	return battler
