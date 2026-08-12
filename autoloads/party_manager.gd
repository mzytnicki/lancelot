extends Node
## Manages the party roster. Autoload as PartyManager.

signal party_member_joined(character: CharacterData)
signal party_member_removed(character: CharacterData)

var members: Array[CharacterData] = []


func _ready() -> void:
	# Start with the hero
	var aiden: CharacterData = load("res://data/characters/aiden.tres")
	if aiden:
		add_member(aiden)


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
