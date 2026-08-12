extends PanelContainer
## Displays quest objectives and current progress.

var _is_open: bool = false

@onready var _quest_list: VBoxContainer = $MarginContainer/VBoxContainer/QuestList
@onready var _detail_label: RichTextLabel = $MarginContainer/VBoxContainer/DetailLabel


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _is_open:
		close()
		get_viewport().set_input_as_handled()


func open_from_pause() -> void:
	_is_open = true
	visible = true
	get_tree().paused = true
	refresh()


func close() -> void:
	_is_open = false
	visible = false
	get_tree().paused = false


func refresh() -> void:
	for child in _quest_list.get_children():
		child.queue_free()

	await get_tree().process_frame

	var active := QuestManager.get_active_quests()
	for quest in active:
		var button := Button.new()
		button.text = quest.title
		button.pressed.connect(_show_detail.bind(quest))
		_quest_list.add_child(button)

	if _quest_list.get_child_count() > 0:
		await get_tree().process_frame
		_quest_list.get_child(0).grab_focus()


func _show_detail(quest: QuestData) -> void:
	var text := "[b]" + quest.title + "[/b]\n\n"
	text += quest.description + "\n\n[b]Objectives:[/b]\n"
	for i in quest.objectives.size():
		var done: bool = false
		if i < quest.objective_flags.size():
			done = GameManager.has_flag(quest.objective_flags[i])
		var marker: String = "✔" if done else "•"
		text += marker + " " + quest.objectives[i] + "\n"
	_detail_label.text = text
