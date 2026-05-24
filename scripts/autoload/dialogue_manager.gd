extends Node

## Lunch-break social dialogue. Progress is tracked per NPC interaction count (persists across days).

const _DIALOGUE_UI := preload("res://scenes/character/DialogueUI.tscn")

const _DIALOGUES: Dictionary = {
	"peter": [
		preload("res://assets/dialogues/peter_01.tres"),
		preload("res://assets/dialogues/peter_02.tres"),
	],
	"lucy": [
		preload("res://assets/dialogues/lucy_01.tres"),
		preload("res://assets/dialogues/lucy_02.tres"),
	],
	"john": [
		preload("res://assets/dialogues/john_01.tres"),
		preload("res://assets/dialogues/john_02.tres"),
	],
}

var interaction_counts: Dictionary = {}
var _dialogue_active: bool = false
var _active_npcs_today: Array = []


func set_active_npcs(active: Array) -> void:
	_active_npcs_today = active.duplicate()


func is_npc_active_today(npc_id: String) -> bool:
	return npc_id in _active_npcs_today


func is_dialogue_window_open() -> bool:
	if not TaskManager.is_timer_active:
		return false
	if TaskManager.is_overtime:
		return false
	if TaskManager.level_time_passed < TaskManager.LUNCH_START_AT_SECONDS:
		return false
	if TaskManager.level_time_remaining <= 0.0:
		return false
	return true


func can_talk(npc_id: String) -> bool:
	if _dialogue_active:
		return false
	if not is_npc_active_today(npc_id):
		return false
	if not is_dialogue_window_open():
		return false
	if get_tree().root.has_node("DialogueUI"):
		return false
	return has_more_dialogue(npc_id)


func has_more_dialogue(npc_id: String) -> bool:
	return _get_current_dialogue(npc_id) != null


func try_start(npc_id: String) -> bool:
	if not can_talk(npc_id):
		return false
	var data: LunchDialogueData = _get_current_dialogue(npc_id)
	if data == null:
		return false
	_run_dialogue(npc_id, data)
	return true


func _get_current_dialogue(npc_id: String) -> LunchDialogueData:
	var list: Array = _DIALOGUES.get(npc_id, [])
	if list.is_empty():
		return null
	var idx: int = int(interaction_counts.get(npc_id, 0))
	if idx >= list.size():
		return null
	return list[idx] as LunchDialogueData


func _run_dialogue(npc_id: String, data: LunchDialogueData) -> void:
	_dialogue_active = true

	var ui: CanvasLayer = _DIALOGUE_UI.instantiate()
	ui.name = "DialogueUI"
	get_tree().root.add_child(ui)

	ui.show_step(data.speaker_name, data.opening_text, data.choice_a_text, data.choice_b_text)
	var picked_a: bool = await ui.choice_made

	if picked_a and data.choice_a_has_followup:
		ui.show_step(data.speaker_name, data.followup_text, data.followup_a_text, data.followup_b_text)
		picked_a = await ui.choice_made
		var feedback := data.followup_a_feedback if picked_a else data.followup_b_feedback
		await ui.show_feedback(feedback)
	else:
		var feedback := data.choice_a_feedback if picked_a else data.choice_b_feedback
		await ui.show_feedback(feedback)

	interaction_counts[npc_id] = int(interaction_counts.get(npc_id, 0)) + 1
	_dialogue_active = false
