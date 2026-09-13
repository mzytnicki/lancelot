extends Resource
class_name CharacterData
## Base data for a party member or NPC.

@export var id: String = ""
@export var display_name: String = ""
@export var animation: SpriteFrames
@export var portrait: Texture2D
@export var overworld_sprite: SpriteFrames

@export_group("Base Stats")
@export var max_hp: int = 100
@export var max_mp: int = 20
@export var max_prouesse: int = 100
@export var max_amour: int = 100
@export var max_courtoisie: int = 100
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
# "0" means unitialized; to be dynamically initialized by max value
var current_xp: int = 0
var current_hp: int = 0  # Tracks HP between battles
var current_mp: int = 0  # Tracks MP between battles
var current_prouesse:   int = 0
var current_amour:      int = 0
var current_courtoisie: int = 0

var equipped_weapon: ItemData = null
var equipped_armor: ItemData = null
var equipped_accessory: ItemData = null


signal hp_change(previous_hp, new_hp)


# A static func belongs to the class itself, not an instance. Call it as
# CharacterData.xp_for_level(5) without needing a CharacterData object.
# Useful for utility calculations that don't depend on instance data.
static func xp_for_level(lev: int) -> int:
	return lev * lev * 10


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


func grant_prouesse(prouesse: int) -> void:
	current_prouesse += prouesse


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


func change_hp(xp: int) -> void:
	hp_change.emit(current_hp, current_hp + xp)
	current_hp = current_hp + xp


func get_effective_attack() -> int:
	var bonus: int = equipped_weapon.attack_bonus if equipped_weapon else 0
	return attack + bonus


func get_effective_defense() -> int:
	var bonus: int = equipped_armor.defense_bonus if equipped_armor else 0
	bonus += equipped_accessory.defense_bonus if equipped_accessory else 0
	return defense + bonus


func get_effective_speed() -> int:
	var bonus: int = 0
	if equipped_accessory:
		bonus += equipped_accessory.speed_bonus
	return speed + bonus


func equip(item: ItemData) -> ItemData:
	## Equips an item, returning the previously equipped item (or null).
	var previous: ItemData = null
	match item.equip_slot:
		ItemData.EquipSlot.WEAPON:
			previous = equipped_weapon
			equipped_weapon = item
		ItemData.EquipSlot.ARMOR:
			previous = equipped_armor
			equipped_armor = item
		ItemData.EquipSlot.ACCESSORY:
			previous = equipped_accessory
			equipped_accessory = item
	return previous


func unequip(slot: ItemData.EquipSlot) -> ItemData:
	var item: ItemData = null
	match slot:
		ItemData.EquipSlot.WEAPON:
			item = equipped_weapon
			equipped_weapon = null
		ItemData.EquipSlot.ARMOR:
			item = equipped_armor
			equipped_armor = null
		ItemData.EquipSlot.ACCESSORY:
			item = equipped_accessory
			equipped_accessory = null
	return item


func predict_equip(candidate: ItemData) -> Dictionary:
	## Returns a stat diff: positive values = improvement, negative = worse.
	## Does NOT modify the character.
	var current_atk := get_effective_attack()
	var current_def := get_effective_defense()
	var current_spd := get_effective_speed()

	# Temporarily swap
	var slot := candidate.equip_slot
	var old_item: ItemData = null
	match slot:
		ItemData.EquipSlot.WEAPON:
			old_item = equipped_weapon
			equipped_weapon = candidate
		ItemData.EquipSlot.ARMOR:
			old_item = equipped_armor
			equipped_armor = candidate
		ItemData.EquipSlot.ACCESSORY:
			old_item = equipped_accessory
			equipped_accessory = candidate

	var diff := {
		attack = get_effective_attack() - current_atk,
		defense = get_effective_defense() - current_def,
		speed = get_effective_speed() - current_spd,
	}

	# Restore original equipment
	match slot:
		ItemData.EquipSlot.WEAPON:
			equipped_weapon = old_item
		ItemData.EquipSlot.ARMOR:
			equipped_armor = old_item
		ItemData.EquipSlot.ACCESSORY:
			equipped_accessory = old_item

	return diff
