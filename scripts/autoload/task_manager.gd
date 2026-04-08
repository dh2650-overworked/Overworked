extends Node

## Autoload: level countdown, task timing, money, signals (Design/PRD + develoment).
## Register a task catalog with register_task_catalog(), then start_level() adds starters and unlocks AUTO_POOL entries over time.

signal task_added(task_instance: TaskInstance)
signal task_removed(instance_id: String)
signal money_updated(new_total: int)
signal nav_requested(instance_id: String)

const LEVEL_DURATION_SECONDS: float = 300.0

var total_money: int = 0

## Counts down from 5:00 (300s) toward 0:00 for the HUD.
var level_time_remaining: float = LEVEL_DURATION_SECONDS

## Seconds elapsed since start_level() (counts up while the level timer is running).
var level_time_passed: float = 0.0

## Unique key -> TaskInstance
var active_tasks: Dictionary = {}

var _next_uid: int = 0

## All TaskData resources for this mode (set via register_task_catalog).
var _task_catalog: Array[TaskData] = []

## AUTO_POOL tasks currently eligible for weighted auto-dispatch (grows as unlock_time is reached).
var _auto_dispatch_pool: Array[TaskData] = []
## task_id -> true once that template has been appended to _auto_dispatch_pool this level.
var _auto_pool_unlocked: Dictionary = {}

var _auto_dispatch_enabled: bool = false
var _auto_interval_min: float = 30.0
var _auto_interval_max: float = 60.0
var _auto_cooldown: float = 0.0


func _process(delta: float) -> void:
	if level_time_remaining > 0.0:
		level_time_remaining = maxf(level_time_remaining - delta, 0.0)
		level_time_passed += delta
		_sync_auto_pool_unlocks()
	if level_time_remaining <= 0.0:
		return
	_tick_task_timers(delta)
	if _auto_dispatch_enabled:
		_auto_cooldown -= delta
		if _auto_cooldown <= 0.0:
			_spawn_auto_dispatch_task()
			_schedule_auto_cooldown()


func _sync_auto_pool_unlocks() -> void:
	var any_new: bool = false
	for t: TaskData in _task_catalog:
		if t == null or t.task_id.is_empty():
			continue
		if t.dispatch_mode != TaskData.DispatchMode.AUTO_POOL:
			continue
		if _auto_pool_unlocked.has(t.task_id):
			continue
		if level_time_passed >= t.unlock_time:
			_auto_dispatch_pool.append(t)
			_auto_pool_unlocked[t.task_id] = true
			any_new = true
	if any_new and _auto_dispatch_enabled and _auto_cooldown <= 0.0 and not _auto_dispatch_pool.is_empty():
		_schedule_auto_cooldown()


func _tick_task_timers(delta: float) -> void:
	var expired: Array[String] = []
	for id: String in active_tasks:
		var inst: TaskInstance = active_tasks[id]
		inst.remaining_time -= delta
		if inst.remaining_time <= 0.0:
			expired.append(id)
	for id: String in expired:
		remove_task(id)


## Call once with every TaskData resource the level should know about (starters + unlock rules read from each .tres).
## Deep-duplicates each entry so catalog slots never share one Resource instance (avoids linked edits / accidental sharing).
func register_task_catalog(task_definitions: Array[TaskData]) -> void:
	_task_catalog.clear()
	for t: TaskData in task_definitions:
		if t == null:
			continue
		var copy: TaskData = t.duplicate(true) as TaskData
		_task_catalog.append(copy if copy != null else t)


## Sets auto-dispatch interval; pool content comes from catalog + unlock_time + AUTO_POOL (not from this call).
func configure_auto_dispatch(
	enabled: bool = true,
	interval_min: float = 30.0,
	interval_max: float = 60.0,
) -> void:
	_auto_interval_min = maxf(interval_min, 0.1)
	_auto_interval_max = maxf(interval_max, _auto_interval_min)
	_auto_dispatch_enabled = enabled


func start_level() -> void:
	level_time_remaining = LEVEL_DURATION_SECONDS
	level_time_passed = 0.0
	_next_uid = 0
	active_tasks.clear()
	total_money = 0
	_auto_dispatch_pool.clear()
	_auto_pool_unlocked.clear()
	money_updated.emit(total_money)
	for t: TaskData in _task_catalog:
		if t != null and t.is_starter_task:
			add_task(t)
	_sync_auto_pool_unlocks()
	if _auto_dispatch_enabled and _auto_dispatch_pool.is_empty():
		_auto_cooldown = 0.0


func _schedule_auto_cooldown() -> void:
	_auto_cooldown = randf_range(_auto_interval_min, _auto_interval_max)


func _spawn_auto_dispatch_task() -> void:
	var pick: TaskData = _pick_weighted_auto_task()
	if pick != null:
		add_task(pick)


func _pick_weighted_auto_task() -> TaskData:
	if _auto_dispatch_pool.is_empty():
		return null
	var total_weight: float = 0.0
	for t: TaskData in _auto_dispatch_pool:
		total_weight += maxf(t.auto_dispatch_weight, 0.001)
	var r: float = randf() * total_weight
	for t: TaskData in _auto_dispatch_pool:
		r -= maxf(t.auto_dispatch_weight, 0.001)
		if r <= 0.0:
			return t
	return _auto_dispatch_pool[_auto_dispatch_pool.size() - 1]


func add_task(data: TaskData) -> void:
	if data == null or data.task_id.is_empty():
		push_warning("TaskManager.add_task: invalid TaskData")
		return
	_next_uid += 1
	var instance_id := "%s#%d" % [data.task_id, _next_uid]
	var inst := TaskInstance.from_task_data(data)
	inst.instance_id = instance_id
	active_tasks[instance_id] = inst
	task_added.emit(inst)


func remove_task(instance_id: String) -> void:
	if not active_tasks.has(instance_id):
		return
	active_tasks.erase(instance_id)
	task_removed.emit(instance_id)


func complete_task(instance_id: String) -> void:
	if not active_tasks.has(instance_id):
		return
	var inst: TaskInstance = active_tasks[instance_id]
	total_money += inst.reward_money
	money_updated.emit(total_money)
	remove_task(instance_id)


func request_navigation(instance_id: String) -> void:
	if active_tasks.has(instance_id):
		nav_requested.emit(instance_id)


func get_instance(instance_id: String) -> TaskInstance:
	return active_tasks.get(instance_id, null)
