class_name BossWeeklyReview
extends RefCounted

const _DIALOGUE_UI := preload("res://scenes/character/DialogueUI.tscn")
const _REVIEW_DATA := preload("res://assets/dialogues/boss_weekly_review.tres")


static func run_if_friday(scene_tree: SceneTree, day_id: String) -> bool:
	if not TaskManager.is_friday(day_id):
		return false

	var game_over := false
	if TaskManager.has_unfinished_tasks():
		TaskManager.unfinished_friday_count += 1
		if TaskManager.unfinished_friday_count >= 2:
			game_over = true

	var pages := _build_pages(day_id)
	if pages.is_empty():
		return game_over

	var ui: CanvasLayer = _DIALOGUE_UI.instantiate()
	ui.name = "BossWeeklyReview"
	ui.process_mode = Node.PROCESS_MODE_ALWAYS
	scene_tree.root.add_child(ui)
	await scene_tree.process_frame
	scene_tree.paused = true
	for page in pages:
		ui.show_tutorial(_REVIEW_DATA.speaker_name, page)
		await ui.tutorial_advance
	scene_tree.paused = false
	ui.queue_free()
	return game_over


static func _build_pages(day_id: String) -> Array[String]:
	var d: BossWeeklyReviewData = _REVIEW_DATA
	var pages: Array[String] = []
	var is_week0 := day_id.begins_with("w0")
	var points := TaskManager.get_week_money_for(day_id)

	_append_nonempty(pages, d.opening_1)
	_append_nonempty(pages, d.opening_2 % points)

	if TaskManager.has_unfinished_tasks():
		if TaskManager.unfinished_friday_count <= 1:
			_append_nonempty(pages, d.unfinished_first_time)
		else:
			_append_nonempty(pages, d.unfinished_second_time)
			return pages
	else:
		_append_nonempty(pages, d.all_finished_intro)
		if TaskManager.had_task_delay_for(day_id):
			_append_nonempty(pages, d.with_delay)
		else:
			_append_nonempty(pages, d.without_delay)

	if TaskManager.week_npc_chat_count >= d.chat_threshold:
		_append_nonempty(pages, d.chat_enough)
	else:
		_append_nonempty(pages, d.chat_too_few)

	if is_week0:
		_append_nonempty(pages, d.ending_week0)
	else:
		_append_nonempty(pages, d.ending_week1)

	return pages


static func _append_nonempty(pages: Array[String], text: String) -> void:
	if text.strip_edges() != "":
		pages.append(text)
