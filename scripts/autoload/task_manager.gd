extends Node

## Autoload: level timer, lunch, money, tasks. Use start_level(day_data) per day scene.

const _DAY_DATA_SCRIPT_PATH := "res://scripts/resources/day_data.gd"

signal task_added(task_instance: TaskInstance)
signal task_removed(instance_id: String)
signal task_cancelled(instance_id: String)
signal inheritance_state_changed()
signal money_updated(new_total: int)
signal nav_requested(instance_id: String)

const LEVEL_DURATION_SECONDS: float = 270.0
const DAY_START_HOUR: int = 8
const SECONDS_PER_GAME_HOUR: float = 30.0
## 8:00 + 16h → 24:00 (midnight); hard end of playable day during overtime.
const MIDNIGHT_PASSED_SECONDS: float = float(24 - DAY_START_HOUR) * SECONDS_PER_GAME_HOUR
const LUNCH_START_AT_SECONDS: float = 120.0
const LUNCH_DURATION_SECONDS: float = 30.0

signal lunch_started()
signal lunch_ended()
signal lunch_acknowledged()
signal summary_requested

# Firedrill code is mostly a copy of Lunch code, 
# TODO: change trigger to specific day, refine popup visuals, add text for label and for button //Erik O
const FIREDRILL_START_AT_SECONDS: float = 230.0
const FIREDRILL_DURATION_SECONDS: float = 20.0
const DAY_HAS_FIREDRILL: bool = true

signal firedrill_started()
signal firedrill_ended()
signal firedrill_acknowledged()
signal create_firedrill()

var firedrill_created: bool = false
var firedrill_active: bool = false
var firedrill_time_remaining: float = 0.0
var firedrill_triggered: bool = false
var firedrill_message_needs_ack: bool = false

var total_money: int = 0
var daily_money: int = 0
var daily_completed_count: int = 0

var level_time_remaining: float = LEVEL_DURATION_SECONDS
var level_time_passed: float = 0.0

var is_timer_active: bool = false
var is_overtime: bool = false

var lunch_active: bool = false
var lunch_time_remaining: float = 0.0
var lunch_triggered: bool = false
var lunch_message_needs_ack: bool = false

var active_tasks: Dictionary = {}

var _next_uid: int = 0
var _current_day_id: String = ""
var _timed_tasks: Dictionary = {}
var _timed_fired: Dictionary = {}

func _process(delta: float) -> void:
	if not is_timer_active:
		return

	if is_overtime:
		level_time_passed = minf(level_time_passed + delta, MIDNIGHT_PASSED_SECONDS)
		return

	if level_time_remaining > 0.0:
		level_time_remaining = maxf(level_time_remaining - delta, 0.0)
		level_time_passed += delta
		_try_fire_timed_tasks()

		if (not lunch_triggered) and level_time_passed >= LUNCH_START_AT_SECONDS:
			lunch_triggered = true
			lunch_active = true
			lunch_time_remaining = LUNCH_DURATION_SECONDS
			lunch_message_needs_ack = true
			lunch_started.emit()

		if lunch_active:
			lunch_time_remaining = maxf(lunch_time_remaining - delta, 0.0)
			if lunch_time_remaining <= 0.0:
				lunch_active = false
				lunch_ended.emit()
		
		if DAY_HAS_FIREDRILL:
			if !firedrill_created and create_firedrill.has_connections():
				create_firedrill.emit()
				firedrill_created = !firedrill_created
			_check_firedrill(delta)

	if level_time_remaining <= 0.0:
		return
	
	if lunch_active:
		return


func start_level(day_data: Resource) -> void:
	# region agent log
	agent_debug_log("A", "task_manager.gd:start_level", "enter", {
		"res_null": day_data == null,
		"is_day_data": _is_day_data(day_data) if day_data != null else false,
	})
	# endregion
	if not _is_day_data(day_data):
		push_warning("TaskManager.start_level: expected a DayData resource")
		# region agent log
		agent_debug_log("A", "task_manager.gd:start_level", "rejected_not_day_data", {})
		# endregion
		return

	var day_key := _day_key(day_data)
	if _current_day_id == day_key and not _current_day_id.is_empty():
		_restart_same_calendar_day(day_data)
		return

	if not _current_day_id.is_empty():
		for inst: TaskInstance in active_tasks.values():
			inst.is_inherited = true
		inheritance_state_changed.emit()

	_current_day_id = day_key
	daily_money = 0
	daily_completed_count = 0
	_reset_level_timer_and_lunch()
	_timed_tasks = _day_timed_tasks(day_data)
	_timed_fired.clear()

	var _st: Array = _day_start_tasks(day_data)
	# region agent log
	agent_debug_log("B", "task_manager.gd:start_level", "start_tasks_array", {"size": _st.size(), "day_key": day_key})
	# endregion
	var _i := 0
	for t: Variant in _st:
		var _is_td: bool = t is TaskData
		var _spath := ""
		if t is Resource and (t as Resource).get_script() != null:
			_spath = str((t as Resource).get_script().resource_path)
		var _tid := ""
		if t is TaskData:
			_tid = (t as TaskData).task_id
		# region agent log
		agent_debug_log("C", "task_manager.gd:start_level", "start_task_row", {
			"i": _i,
			"is_taskdata": _is_td,
			"variant_type": typeof(t),
			"script_path": _spath,
			"task_id": _tid,
		})
		# endregion
		_i += 1
		if t is TaskData:
			add_task(t as TaskData)

	money_updated.emit(total_money)


func _restart_same_calendar_day(day_data: Resource) -> void:
	daily_money = 0
	daily_completed_count = 0
	_reset_level_timer_and_lunch()
	_timed_tasks = _day_timed_tasks(day_data)
	_timed_fired.clear()

	var to_cancel: Array[String] = []
	for id: String in active_tasks:
		var inst: TaskInstance = active_tasks[id]
		if not inst.is_inherited:
			to_cancel.append(id)
	for id: String in to_cancel:
		_cancel_task(id)

	for t: Variant in _day_start_tasks(day_data):
		if t is TaskData:
			add_task(t as TaskData)

	money_updated.emit(total_money)


func _is_day_data(res: Resource) -> bool:
	if res == null:
		return false
	var s: Script = res.get_script() as Script
	return s != null and s.resource_path == _DAY_DATA_SCRIPT_PATH


func _day_key(day_data: Resource) -> String:
	var id_var: Variant = day_data.get("day_id")
	var id: String = str(id_var) if id_var != null else ""
	if not id.is_empty():
		return id
	return day_data.resource_path


func _day_start_tasks(day_data: Resource) -> Array:
	var st: Variant = day_data.get("start_tasks")
	return st as Array if st is Array else []


func _day_timed_tasks(day_data: Resource) -> Dictionary:
	var td: Variant = day_data.get("timed_tasks")
	return td as Dictionary if td is Dictionary else {}


func _reset_level_timer_and_lunch() -> void:
	level_time_remaining = LEVEL_DURATION_SECONDS
	level_time_passed = 0.0
	is_overtime = false
	lunch_active = false
	lunch_time_remaining = 0.0
	lunch_triggered = false
	lunch_message_needs_ack = false


func _try_fire_timed_tasks() -> void:
	if _timed_tasks.is_empty():
		return
	for key in _timed_tasks.keys():
		if _timed_fired.get(key, false):
			continue
		var at_sec: float = _dict_key_to_seconds(key)
		if level_time_passed < at_sec:
			continue
		if lunch_active:
			# region agent log
			agent_debug_log("F", "task_manager.gd:_try_fire_timed_tasks", "skip_due_lunch", {
				"key": str(key),
				"at_sec": at_sec,
				"level_time_passed": level_time_passed,
			})
			# endregion
			continue
		_timed_fired[key] = true
		var td: TaskData = _timed_tasks[key] as TaskData
		if td != null:
			add_task(td)


func _dict_key_to_seconds(key: Variant) -> float:
	match typeof(key):
		TYPE_FLOAT:
			return key as float
		TYPE_INT:
			return float(key as int)
		TYPE_STRING:
			return float(key as String)
		_:
			return float(str(key))


func add_task(data: TaskData, bypass_lunch: bool = false) -> void:
	# region agent log
	agent_debug_log("D", "task_manager.gd:add_task", "enter", {
		"lunch_active": lunch_active,
		"bypass_lunch": bypass_lunch,
		"data_null": data == null,
		"task_id": data.task_id if data != null else "",
	})
	# endregion
	if lunch_active and not bypass_lunch:
		# region agent log
		agent_debug_log("D", "task_manager.gd:add_task", "skip_lunch", {})
		# endregion
		return
	if data == null or data.task_id.is_empty():
		push_warning("TaskManager.add_task: invalid TaskData")
		# region agent log
		agent_debug_log("D", "task_manager.gd:add_task", "skip_invalid", {})
		# endregion
		return
	_next_uid += 1
	var instance_id := "%s#%d" % [data.task_id, _next_uid]
	var inst := TaskInstance.from_task_data(data)
	inst.instance_id = instance_id
	inst.is_inherited = false
	active_tasks[instance_id] = inst
	# region agent log
	agent_debug_log("D", "task_manager.gd:add_task", "emit_task_added", {"instance_id": instance_id})
	# endregion
	task_added.emit(inst)


func _cancel_task(instance_id: String) -> void:
	if not active_tasks.has(instance_id):
		return
	active_tasks.erase(instance_id)
	task_cancelled.emit(instance_id)


func remove_task(instance_id: String) -> void:
	if not active_tasks.has(instance_id):
		return
	active_tasks.erase(instance_id)
	task_removed.emit(instance_id)


func complete_task(instance_id: String) -> void:
	if not active_tasks.has(instance_id):
		return
	var inst: TaskInstance = active_tasks[instance_id]
	daily_money += inst.reward_money
	total_money += inst.reward_money
	daily_completed_count += 1
	money_updated.emit(total_money)
	remove_task(instance_id)


func complete_task_by_type(target_task_id: String) -> void:
	for id in active_tasks:
		var inst = active_tasks[id]
		if inst.task_id == target_task_id:
			complete_task(id)
			return

func increment_task(target_task_id: String) -> void:
	for id in active_tasks:
		var inst: TaskInstance = active_tasks[id]
		if inst.task_id == target_task_id:
			inst.current_count += 1
			if inst.current_count >= inst.max_count:
				complete_task(id)
			else:
				task_added.emit(inst)  # re-emit to refresh the UI label
			return

func request_navigation(instance_id: String) -> void:
	if active_tasks.has(instance_id):
		nav_requested.emit(instance_id)


func acknowledge_lunch_message() -> void:
	if lunch_message_needs_ack:
		lunch_message_needs_ack = false
		lunch_acknowledged.emit()

func _check_firedrill(delta: float) -> void:
	if (not firedrill_triggered) and level_time_passed >= FIREDRILL_START_AT_SECONDS:
			firedrill_triggered = true
			firedrill_active = true
			firedrill_time_remaining = FIREDRILL_DURATION_SECONDS
			firedrill_message_needs_ack = true
			firedrill_started.emit()

	if firedrill_active:
		firedrill_time_remaining = maxf(firedrill_time_remaining - delta, 0.0)
		if firedrill_time_remaining <= 0.0:
			firedrill_active = false
			firedrill_ended.emit()

func acknowledge_firedrill_message() -> void:
	if firedrill_message_needs_ack:
		firedrill_message_needs_ack = false
		firedrill_acknowledged.emit()

func get_instance(instance_id: String) -> TaskInstance:
	return active_tasks.get(instance_id, null)


## Wipes run state for a fresh playthrough (tasks, money, day id, timers).
func reset_for_new_game() -> void:
	var ids: Array = active_tasks.keys()
	for id: Variant in ids:
		_cancel_task(str(id))
	total_money = 0
	daily_money = 0
	daily_completed_count = 0
	_next_uid = 0
	_current_day_id = ""
	_timed_tasks.clear()
	_timed_fired.clear()
	_reset_level_timer_and_lunch()
	money_updated.emit(total_money)


# region agent log
func agent_debug_log(hypothesis_id: String, location: String, message: String, data: Dictionary) -> void:
	var payload := {
		"sessionId": "4fe433",
		"hypothesisId": hypothesis_id,
		"location": location,
		"message": message,
		"data": data,
		"timestamp": Time.get_ticks_msec(),
	}
	var line := JSON.stringify(payload)
	for prefix in ["user://debug-4fe433.log", "res://debug-4fe433.log"]:
		var log_path := ProjectSettings.globalize_path(prefix)
		var f: FileAccess = FileAccess.open(log_path, FileAccess.READ_WRITE)
		if f == null:
			f = FileAccess.open(log_path, FileAccess.WRITE)
		if f:
			f.seek_end()
			f.store_line(line)
			f.close()

func has_unfinished_tasks() -> bool:
	# Determine whether to display the overtime panel
	for task_instance in active_tasks.values(): 
		return true 
	return false #finish all the tasks
# endregion
