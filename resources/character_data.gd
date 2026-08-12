extends Resource
class_name CharacterData
## Base data for a party member or NPC.

@export var id: String = ""
@export var display_name: String = ""
@export var portrait: Texture2D
@export var overworld_sprite: SpriteFrames

@export_group("Base Stats")
@export var max_hp: int = 100
@export var max_mp: int = 20
@export var attack: int = 10
@export var defense: int = 8
@export var speed: int = 10
@export var level: int = 1

@export_group("Growth per Level")
@export var hp_growth: int = 12
@export var mp_growth: int = 4
@export var attack_growth: int = 2
@export var defense_growth: int = 1
@export var speed_growth: int = 1

# Runtime state (set in code, not in the Inspector)
var current_xp: int = 0
var current_hp: int = 0  # Tracks HP between battles
var current_mp: int = 0  # Tracks MP between battles


# A static func belongs to the class itself, not an instance. Call it as
# CharacterData.xp_for_level(5) without needing a CharacterData object.
# Useful for utility calculations that don't depend on instance data.
static func xp_for_level(level: int) -> int:
	return level * level * 10


func level_up() -> Dictionary:
	level += 1
	var gains: Dictionary = {
		hp = hp_growth + randi_range(0, 2),
		mp = mp_growth + randi_range(0, 1),
		attack = attack_growth + randi_range(0, 1),
		defense = defense_growth + randi_range(0, 1),
		speed = speed_growth,
	}
	var old_max_hp: int = max_hp
	var old_max_mp: int = max_mp
	max_hp += gains.hp
	max_mp += gains.mp
	current_hp = min(current_hp + (max_hp - old_max_hp), max_hp)
	current_mp = min(current_mp + (max_mp - old_max_mp), max_mp)
	attack += gains.attack
	defense += gains.defense
	speed += gains.speed
	return gains


func grant_xp(xp: int) -> Array[Dictionary]:
	current_xp += xp

	var level_ups: Array[Dictionary] = []
	var required: int = CharacterData.xp_for_level(level)
	while current_xp >= required:
		current_xp -= required
		var gains: Dictionary = level_up()
		level_ups.append({
			level = level,
			gains = gains,
		})
		required = CharacterData.xp_for_level(level)

	return level_ups
