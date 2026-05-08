extends Node2D

## Each day scene: assign a DayData .tres in the inspector (Resource slot).

const Whiteboard := preload("res://assets/tasks/whiteboard.tres")
const _DAY_DATA_SCRIPT_PATH := "res://scripts/resources/day_data.gd"

@export var day_data: Resource

@onready var _time_label: Label = $CanvasLayer/Clock/TimeLabel
@onready var _money_label: Label = $CanvasLayer/MoneyLabel/Bg/Label
@onready var _lunch_banner: PanelContainer = $CanvasLayer/LunchBanner
@onready var _lunch_banner_label: Label = $CanvasLayer/LunchBanner/VBoxContainer/Label
@onready var _lunch_confirm_button: Button = $CanvasLayer/LunchBanner/VBoxContainer/ConfirmButton
@onready var _summary_panel: Control = $CanvasLayer/SummaryPanel
@onready var _salary_val: Label = $CanvasLayer/SummaryPanel/MarginContainer/Stats/SalaryLabel
@onready var _task_count_val: Label = $CanvasLayer/SummaryPanel/MarginContainer/Stats/TaskCountLabel
@onready var _balance_val: Label = $CanvasLayer/SummaryPanel/MarginContainer/Stats/BalanceLabel


func _is_day_data_resource(res: Resource) -> bool:
	if res == null:
		return false
	var s: Script = res.get_script() as Script
	return s != null and s.resource_path == _DAY_DATA_SCRIPT_PATH


func _ready() -> void:
	# region agent log
	var _ds: Script = day_data.get_script() as Script if day_data != null else null
	TaskManager.agent_debug_log("A", "main.gd:_ready", "enter_main_ready", {
		"day_data_null": day_data == null,
		"script_path": _ds.resource_path if _ds != null else "",
		"path_match": _ds.resource_path == _DAY_DATA_SCRIPT_PATH if _ds != null else false,
	})
	# endregion
	TaskManager.nav_requested.connect(_on_nav_requested)
	TaskManager.money_updated.connect(_on_money_updated)
	TaskManager.lunch_started.connect(_on_lunch_started)
	TaskManager.lunch_ended.connect(_on_lunch_ended)
	TaskManager.lunch_acknowledged.connect(_on_lunch_acknowledged)
	if day_data != null and _is_day_data_resource(day_data):
		TaskManager.start_level(day_data)
	elif day_data != null:
		push_warning("Main: day_data must be a DayData resource (.tres).")
	else:
		push_warning("Main: day_data is not set; no tasks will be scheduled.")
	_on_money_updated(TaskManager.total_money)
	_update_level_clock()
	_lunch_banner.visible = false
	_lunch_confirm_button.pressed.connect(_on_lunch_confirm_pressed)
	_summary_panel.visible = false


func _process(_delta: float) -> void:
	_update_level_clock()


func _update_level_clock() -> void:
	var passed: float = TaskManager.level_time_passed
	var remaining: float = TaskManager.level_time_remaining
	var hours_passed: int = int(passed / 30.0)
	var current_hour: int = 8 + hours_passed

	var time_text: String = ""
	if current_hour < 12:
		time_text = str(current_hour) + " am"
	elif current_hour == 12:
		time_text = "12 pm"
	else:
		time_text = str(current_hour - 12) + " pm"

	_time_label.text = time_text

	if remaining <= 0.0 and not _summary_panel.visible:
		_show_summary()


func _on_money_updated(new_total: int) -> void:
	var quota = 300
	_money_label.text = str(TaskManager.daily_money) + " / " + str(quota) + " $"


func _on_nav_requested(instance_id: String) -> void:
	var inst: TaskInstance = TaskManager.get_instance(instance_id)
	if not inst:
		print("错误：找不到任务实例 ", instance_id)
		return

	var found_path: String = inst.scene_path
	print("尝试为任务查找场景路径: ", inst.task_id)

	if found_path != "":
		print("成功找到路径: ", found_path)
		if ResourceLoader.exists(found_path):
			var scene = load(found_path)
			var task_ui = scene.instantiate()
			add_child(task_ui)
			print("界面已弹出！")
		else:
			print("错误：路径存在但文件不存在！", found_path)
	else:
		print("提示：该任务没有配置 Scene Path，仅执行普通导航。")


func _on_lunch_started() -> void:
	_lunch_banner.visible = true


func _on_lunch_ended() -> void:
	_lunch_banner.visible = false


func _on_lunch_acknowledged() -> void:
	_lunch_banner.visible = false


func _on_lunch_confirm_pressed() -> void:
	TaskManager.acknowledge_lunch_message()
	_lunch_banner.visible = false


func _show_summary() -> void:
	_summary_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	get_tree().paused = true
	_salary_val.text = "Salary: " + str(TaskManager.daily_money)
	_task_count_val.text = "Tasks Completed: " + str(TaskManager.daily_completed_count)
	_balance_val.text = "Final Balance: " + str(TaskManager.total_money)
	_summary_panel.visible = true


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
					"level_remaining=%.1f passed=%.1f total_money=%d daily_money=%d daily_done=%d active=%d"
					% [
						TaskManager.level_time_remaining,
						TaskManager.level_time_passed,
						TaskManager.total_money,
						TaskManager.daily_money,
						TaskManager.daily_completed_count,
						TaskManager.active_tasks.size(),
					]
				)


func _on_yes_button_pressed() -> void:
	$CanvasLayer/ConfirmOverlay.hide()
	_show_summary()
