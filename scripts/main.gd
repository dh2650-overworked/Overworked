extends Node

## Demo: task catalog + starters / unlock times come from each TaskData .tres (see TaskManager).

const FILL_FORM := preload("res://assets/tasks/fill_form.tres")
const RECEPTION := preload("res://assets/tasks/reception.tres")
const COFFEE := preload("res://assets/tasks/coffee.tres")
const APPROVE_FILE := preload("res://assets/tasks/approve_file.tres")

@onready var _time_label: Label = $CanvasLayer/TimeLabel/Bg/Label
@onready var _money_label: Label = $CanvasLayer/MoneyLabel/Bg/Label


func _ready() -> void:
	TaskManager.nav_requested.connect(_on_nav_requested)
	TaskManager.money_updated.connect(_on_money_updated)
	TaskManager.register_task_catalog([FILL_FORM, RECEPTION, COFFEE, APPROVE_FILE])
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
				TaskManager.add_task(RECEPTION)
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
