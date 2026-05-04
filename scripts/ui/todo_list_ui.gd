extends Control

## Work List panel only (signal-driven). Top offset = viewport width * 0.2 (PRD §1).

const TASK_ITEM_SCENE := preload("res://scenes/ui/task_item.tscn")

@onready var _toggle_button: Button = $VBoxContainer/HBox/ToggleButton
@onready var _panel: PanelContainer = $VBoxContainer/PanelContainer
@onready var _vbox: VBoxContainer = $VBoxContainer/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer
@onready var _header_row: HBoxContainer = $VBoxContainer/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/HeaderRow

var _expanded: bool = false
var _items: Dictionary = {}


func _ready() -> void:
	_toggle_button.pressed.connect(_on_toggle_pressed)
	TaskManager.task_added.connect(_on_task_added)
	TaskManager.task_removed.connect(_on_task_removed)
	TaskManager.task_cancelled.connect(_on_task_cancelled)
	TaskManager.inheritance_state_changed.connect(_on_inheritance_state_changed)
	# region agent log
	TaskManager.agent_debug_log("E", "todo_list_ui.gd:_ready", "signals_connected", {"active_tasks": TaskManager.active_tasks.size()})
	# endregion
	_panel.visible = false
	_header_row.visible = false
	call_deferred("_deferred_sync_all_task_rows")


func _on_toggle_pressed() -> void:
	_expanded = not _expanded

	if _expanded:
		_panel.visible = true
		_header_row.visible = true
		_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
		var tween := create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(_panel, "modulate:a", 1.0, 0.2)
	else:
		var tween := create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(_panel, "modulate:a", 0.0, 0.15)
		tween.tween_callback(func():
			_panel.visible = false
			_header_row.visible = false
		)


func _on_task_added(task_instance: TaskInstance) -> void:
	# region agent log
	TaskManager.agent_debug_log("E", "todo_list_ui.gd:_on_task_added", "received", {"instance_id": task_instance.instance_id})
	# endregion
	var item: Node = TASK_ITEM_SCENE.instantiate()
	_vbox.add_child(item)
	item.setup(task_instance)
	_items[task_instance.instance_id] = item
	_move_header_to_front()


func _move_header_to_front() -> void:
	if _header_row.get_parent() == _vbox:
		_vbox.move_child(_header_row, 0)


func _on_task_removed(instance_id: String) -> void:
	if _items.has(instance_id):
		var node: Node = _items[instance_id]
		_items.erase(instance_id)
		if node.has_method("mark_as_completed"):
			node.mark_as_completed()


func _on_task_cancelled(instance_id: String) -> void:
	if not _items.has(instance_id):
		return
	var node: Node = _items[instance_id]
	_items.erase(instance_id)
	node.queue_free()


func _on_inheritance_state_changed() -> void:
	var _added := 0
	for instance_id: String in TaskManager.active_tasks:
		var inst: TaskInstance = TaskManager.get_instance(instance_id)
		if inst == null:
			continue
		if not _items.has(instance_id):
			var item: Node = TASK_ITEM_SCENE.instantiate()
			_vbox.add_child(item)
			item.setup(inst)
			_items[instance_id] = item
			_move_header_to_front()
			_added += 1
		else:
			var node: Node = _items[instance_id]
			if node.has_method("setup"):
				node.setup(inst)
	# region agent log
	TaskManager.agent_debug_log("A", "todo_list_ui.gd:_on_inheritance_state_changed", "synced", {
		"added_rows": _added,
		"active_total": TaskManager.active_tasks.size(),
	})
	# endregion


func _deferred_sync_all_task_rows() -> void:
	var _added := 0
	for instance_id: Variant in TaskManager.active_tasks:
		var sid: String = str(instance_id)
		if _items.has(sid):
			continue
		var inst: TaskInstance = TaskManager.get_instance(sid)
		if inst == null:
			continue
		var item: Node = TASK_ITEM_SCENE.instantiate()
		_vbox.add_child(item)
		item.setup(inst)
		_items[sid] = item
		_move_header_to_front()
		_added += 1
	if _added > 0:
		# region agent log
		TaskManager.agent_debug_log("A", "todo_list_ui.gd:_deferred_sync_all_task_rows", "backfill", {
			"added_rows": _added,
			"active_total": TaskManager.active_tasks.size(),
		})
		# endregion
