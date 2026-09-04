extends Node
## Manages the party roster. Autoload as PartyManager.

signal party_member_joined(character: CharacterData)
signal party_member_removed(character: CharacterData)

var members: Array[CharacterData] = []


func _ready() -> void:
	var lancelot_data := ResourceLoader.load(
		"res://data/characters/lancelot.tres", "", ResourceLoader.CACHE_MODE_IGNORE,
	) as CharacterData
	if lancelot_data:
		lancelot_data.current_hp = lancelot_data.max_hp
		lancelot_data.current_mp = lancelot_data.max_mp
		lancelot_data.current_prouesse = 10
		lancelot_data.current_amour = 10
		lancelot_data.current_courtoisie = 10
		lancelot_data.current_xp = 0
		PartyManager.add_member(lancelot_data)



func add_member(character: CharacterData) -> void:
	if not members.has(character):
		members.append(character)
		party_member_joined.emit(character)


func remove_member(character: CharacterData) -> void:
	if members.has(character):
		members.erase(character)
		party_member_removed.emit(character)


func get_members() -> Array[CharacterData]:
	return members.duplicate()


func get_member_by_id(id: String) -> CharacterData:
	for member in members:
		if member.id == id:
			return member
	return null


func award_xp_to_party(xp_per_member: int) -> void:
	if xp_per_member <= 0:
		return

	for member in members:
		print(member.display_name + " gained " + str(xp_per_member) + " XP!")
		for result in member.grant_xp(xp_per_member):
			var gains: Dictionary = result.gains
			print(member.display_name + " reached level " + str(result.level) + "!")
			print("  HP +" + str(gains.hp) + ", ATK +" + str(gains.attack) +
				  ", DEF +" + str(gains.defense))


func to_save_data() -> Dictionary:
	var members_data: Array[Dictionary] = []
	for member in members:
		members_data.append({
			id = member.id,
			path = member.resource_path,
			level = member.level,
			current_xp = member.current_xp,
			max_hp = member.max_hp,
			max_mp = member.max_mp,
			attack = member.attack,
			defense = member.defense,
			speed = member.speed,
			current_hp = member.current_hp,
			current_mp = member.current_mp,
			weapon_path = member.equipped_weapon.resource_path if member.equipped_weapon else "",
			armor_path = member.equipped_armor.resource_path if member.equipped_armor else "",
			accessory_path = member.equipped_accessory.resource_path if member.equipped_accessory else "",
		})
	return {members = members_data}


func from_save_data(data: Dictionary) -> void:
	members.clear()
	for entry in data.get("members", []):
		var character := ResourceLoader.load(
			entry.path, "", ResourceLoader.CACHE_MODE_IGNORE,
		) as CharacterData
		if character:
			character.level = int(entry.get("level", 1))
			character.current_xp = int(entry.get("current_xp", 0))
			character.max_hp = int(entry.get("max_hp", character.max_hp))
			character.max_mp = int(entry.get("max_mp", character.max_mp))
			character.attack = int(entry.get("attack", character.attack))
			character.defense = int(entry.get("defense", character.defense))
			character.speed = int(entry.get("speed", character.speed))
			character.current_hp = int(entry.get("current_hp", character.max_hp))
			character.current_mp = int(entry.get("current_mp", character.max_mp))
			var weapon_path: String = entry.get("weapon_path", "")
			if weapon_path:
				character.equipped_weapon = load(weapon_path) as ItemData
			var armor_path: String = entry.get("armor_path", "")
			if armor_path:
				character.equipped_armor = load(armor_path) as ItemData
			var accessory_path: String = entry.get("accessory_path", "")
			if accessory_path:
				character.equipped_accessory = load(accessory_path) as ItemData
			members.append(character)
