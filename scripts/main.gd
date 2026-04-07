extends Node

## Demo: task catalog + starters / unlock times come from each TaskData .tres (see TaskManager).

const Whiteboard := preload("res://assets/tasks/whiteboard.tres")
const Water_cooler := preload("res://assets/tasks/water_cooler.tres")
const Respond_email := preload("res://assets/tasks/respond_email.tres")
const Report_Writing := preload("res://assets/tasks/report_writing.tres")

@onready var _time_label: Label = $CanvasLayer/TimeLabel/Bg/Label
@onready var _money_label: Label = $CanvasLayer/MoneyLabel/Bg/Label


func _ready() -> void:
	TaskManager.nav_requested.connect(_on_nav_requested)
	TaskManager.money_updated.connect(_on_money_updated)
	TaskManager.register_task_catalog([Whiteboard, Water_cooler, Respond_email, Report_Writing])
	TaskManager.configure_auto_dispatch(true, 10.0, 20.0)
	TaskManager.start_level()
	_on_money_updated(TaskManager.total_money)
	_update_level_clock()


func _process(_delta: float) -> void:
	_update_level_clock()


func _update_level_clock() -> void:
	var secs: int = int(floor(TaskManager.level_time_remaining))
	secs = maxi(secs, 0)
	var m: int = secs / 60
	var s: int = secs % 60
	_time_label.text = "%d:%02d" % [m, s]


func _on_money_updated(new_total: int) -> void:
	_money_label.text = str(new_total)


func _on_nav_requested(instance_id: String) -> void:
	var inst: TaskInstance = TaskManager.get_instance(instance_id)
	var name := inst.task_name if inst else instance_id
	print("Navigating to task: ", name, " (", instance_id, ")")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_R:
				TaskManager.add_task(Whiteboard)
			KEY_F:
				var ids: Array = TaskManager.active_tasks.keys()
				if not ids.is_empty():
					TaskManager.complete_task(ids[0])
			KEY_T:
				print(
					"level_remaining=%.1f passed=%.1f money=%d tasks=%d"
					% [
						TaskManager.level_time_remaining,
						TaskManager.level_time_passed,
						TaskManager.total_money,
						TaskManager.active_tasks.size(),
					]
				)
