extends Node

## Demo: task catalog + starters / unlock times come from each TaskData .tres (see TaskManager).

const Whiteboard := preload("res://assets/tasks/whiteboard.tres")
const Water_cooler := preload("res://assets/tasks/water_cooler.tres")
const Respond_email := preload("res://assets/tasks/respond_email.tres")
const Report_Writing := preload("res://assets/tasks/report_writing.tres")
const Water_Plant := preload("res://assets/tasks/water_plant.tres")
const Print_Document := preload("res://assets/tasks/printer.tres")

@onready var _time_label: Label = $CanvasLayer/Clock/TimeLabel
@onready var _money_label: Label = $CanvasLayer/MoneyLabel/Bg/Label
@onready var _lunch_banner: PanelContainer = $CanvasLayer/LunchBanner
@onready var _lunch_banner_label: Label = $CanvasLayer/LunchBanner/VBoxContainer/Label
@onready var _lunch_confirm_button: Button = $CanvasLayer/LunchBanner/VBoxContainer/ConfirmButton
@onready var _summary_panel: Control = $CanvasLayer/SummaryPanel
@onready var _salary_val: Label = $CanvasLayer/SummaryPanel/MarginContainer/Stats/SalaryLabel
@onready var _task_count_val: Label = $CanvasLayer/SummaryPanel/MarginContainer/Stats/TaskCountLabel
@onready var _balance_val: Label = $CanvasLayer/SummaryPanel/MarginContainer/Stats/BalanceLabel
@onready var _next_level_button: Button = $CanvasLayer/SummaryPanel/MarginContainer/Buttons/NextLevelButton
@onready var _main_menu_button: Button = $CanvasLayer/SummaryPanel/MarginContainer/Buttons/MainMenuButton


func _ready() -> void:
	TaskManager.nav_requested.connect(_on_nav_requested)
	TaskManager.money_updated.connect(_on_money_updated)
	TaskManager.lunch_started.connect(_on_lunch_started)
	TaskManager.lunch_ended.connect(_on_lunch_ended)
	TaskManager.lunch_acknowledged.connect(_on_lunch_acknowledged)
	TaskManager.register_task_catalog([Whiteboard, Water_cooler, Respond_email, Report_Writing, Water_Plant, Print_Document])
	TaskManager.configure_auto_dispatch(true, 150.0, 300.0)
ds	TaskManager.start_level()
	_on_money_updated(TaskManager.total_money)
	_update_level_clock()
	_lunch_banner.visible = false
	_lunch_confirm_button.pressed.connect(_on_lunch_confirm_pressed)
	_summary_panel.visible = false
	_next_level_button.pressed.connect(_on_next_level_pressed)
	_main_menu_button.pressed.connect(_on_main_menu_pressed)


func _process(_delta: float) -> void:
	_update_level_clock()


func _update_level_clock() -> void:
	var passed: float = TaskManager.level_time_passed # 获取已流逝的时间
	var remaining: float = TaskManager.level_time_remaining
	# Calculate the current hour (one hour is every 30 seconds).
	var hours_passed: int = int(passed / 30.0)
	# starting from 8 am
	var current_hour: int = 8 + hours_passed
	
	var time_text: String = ""
	if current_hour < 12:
		time_text = str(current_hour) + " am"
	elif current_hour == 12:
		time_text = "12 pm"
	else:
		# Convert to a 12-hour clock (show as 1 pm)
		time_text = str(current_hour - 12) + " pm"
	
	_time_label.text = time_text
	
	# game ending
	if remaining <= 0.0 and not _summary_panel.visible:
		_show_summary()


func _on_money_updated(new_total: int) -> void:
	_money_label.text = str(new_total)


func _on_nav_requested(instance_id: String) -> void:
	var inst: TaskInstance = TaskManager.get_instance(instance_id)
	if not inst: 
		print("错误：找不到任务实例 ", instance_id)
		return

	print("尝试为任务查找场景路径: ", inst.task_id)

	var found_path: String = ""
	for t in TaskManager._task_catalog:
		if t.task_id == inst.task_id:
			found_path = t.scene_path
			break
	
	if found_path != "":
		print("成功找到路径: ", found_path)
		# 检查文件是否存在
		if ResourceLoader.exists(found_path):
			var scene = load(found_path)
			var task_ui = scene.instantiate()
			# 直接加到当前场景，或者加到 CanvasLayer
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
	_salary_val.text = "Salary: " + str(TaskManager.total_money)
	_task_count_val.text = "Tasks Completed: " + str(TaskManager.tasks_completed_count)
	_balance_val.text = "Final Balance: " + str(TaskManager.total_money)
	_summary_panel.visible = true


func _on_next_level_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


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
