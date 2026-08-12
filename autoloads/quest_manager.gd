extends Node
## Tracks active quests and checks objectives. Autoload as QuestManager.

signal quest_started(quest: QuestData)
signal quest_completed(quest: QuestData)
signal quest_turned_in(quest: QuestData)

var _active_quests: Array[QuestData] = []
var _completed_quests: Array[QuestData] = []
var _turned_in_quests: Array[QuestData] = []


func _ready() -> void:
	GameManager.flag_changed.connect(_on_flag_changed)


func start_quest(quest: QuestData) -> void:
	if _is_quest_active(quest.id) or is_quest_complete(quest.id) or _is_quest_done(quest.id):
		return
	_active_quests.append(quest)
	quest_started.emit(quest)


func is_quest_active(quest_id: String) -> bool:
	return _is_quest_active(quest_id)


func is_quest_complete(quest_id: String) -> bool:
	for q in _completed_quests:
		if q.id == quest_id:
			return true
	return false


func get_quest_state(quest_id: String) -> QuestData.QuestState:
	if _is_quest_done(quest_id):
		return QuestData.QuestState.TURNED_IN
	if is_quest_complete(quest_id):
		return QuestData.QuestState.COMPLETE
	if is_quest_active(quest_id):
		return QuestData.QuestState.ACTIVE
	return QuestData.QuestState.NOT_STARTED


func turn_in_quest(quest: QuestData) -> bool:
	if not quest:
		return false
	return turn_in_quest_by_id(quest.id)


func turn_in_quest_by_id(quest_id: String) -> bool:
	var quest: QuestData = null
	for candidate in _completed_quests:
		if candidate.id == quest_id:
			quest = candidate
			break

	if not quest:
		return false

	_completed_quests.erase(quest)
	_turned_in_quests.append(quest)

	if quest.xp_reward > 0:
		PartyManager.award_xp_to_party(quest.xp_reward)
	if quest.gold_reward > 0:
		InventoryManager.add_gold(quest.gold_reward)
	for item in quest.reward_items:
		InventoryManager.add_item(item)
	if not quest.completion_flag.is_empty():
		GameManager.set_flag(quest.completion_flag)

	quest_turned_in.emit(quest)
	return true


func get_active_quests() -> Array[QuestData]:
	return _active_quests.duplicate()


func get_completed_quests() -> Array[QuestData]:
	return _completed_quests.duplicate()


func get_turned_in_quests() -> Array[QuestData]:
	return _turned_in_quests.duplicate()


func _on_flag_changed(flag_name: String, _value: bool) -> void:
	# Check if any active quest's objectives are now all met
	# Collect completed quests first; don't modify the array during iteration
	var newly_completed: Array[QuestData] = []
	for quest in _active_quests:
		if _all_objectives_met(quest):
			newly_completed.append(quest)
	for quest in newly_completed:
		_active_quests.erase(quest)
		_completed_quests.append(quest)
		quest_completed.emit(quest)


func _all_objectives_met(quest: QuestData) -> bool:
	for flag in quest.objective_flags:
		if not GameManager.has_flag(flag):
			return false
	return true


func _is_quest_active(quest_id: String) -> bool:
	return _active_quests.any(func(q: QuestData) -> bool: return q.id == quest_id)


func _is_quest_done(quest_id: String) -> bool:
	return _turned_in_quests.any(func(q: QuestData) -> bool: return q.id == quest_id)
