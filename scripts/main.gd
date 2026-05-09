extends Node2D

## Each day scene: assign a DayData .tres in the inspector (Resource slot).

const Whiteboard := preload("res://assets/tasks/whiteboard.tres")
const _DAY_DATA_SCRIPT_PATH := "res://scripts/resources/day_data.gd"

@export var day_data: Resource

@onready var _time_label: Label = $UI/Clock/TimeLabel
@onready var _money_label: Label = $UI/MoneyLabel/Bg/Label
@onready var _lunch_banner: PanelContainer = $UI/LunchBanner
@onready var _firedrill_banner: PanelContainer = $UI/FireBanner
@onready var _lunch_banner_label: Label = $UI/LunchBanner/VBoxContainer/Label
@onready var _lunch_confirm_button: Button = $UI/LunchBanner/VBoxContainer/ConfirmButton

# --- NEW: Reference to your Fire Drill Button ---
@onready var _firedrill_button: Button = $UI/FireBanner/VBoxContainer/ConfirmButton

@onready var _summary_panel: Control = $UI/SummaryPanel
@onready var _salary_val: Label = $UI/SummaryPanel/MarginContainer/Stats/SalaryLabel
@onready var _task_count_val: Label = $UI/SummaryPanel/MarginContainer/Stats/TaskCountLabel
@onready var _balance_val: Label = $UI/SummaryPanel/MarginContainer/Stats/BalanceLabel

# To prevent the fire from re-triggering every frame after you close it
var fire_drill_triggered_today: bool = false 

func _is_day_data_resource(res: Resource) -> bool:
	if res == null:
		return false
	var s: Script = res.get_script() as Script
	return s != null and s.resource_path == _DAY_DATA_SCRIPT_PATH


func _ready() -> void:
	# --- 1. Basic TaskManager connections ---
	TaskManager.nav_requested.connect(_on_nav_requested)
	TaskManager.money_updated.connect(_on_money_updated)
	TaskManager.lunch_started.connect(_on_lunch_started)
	TaskManager.lunch_ended.connect(_on_lunch_ended)
	TaskManager.lunch_acknowledged.connect(_on_lunch_acknowledged)

	# --- 2. FireManager Integration ---
	if Engine.has_singleton("FireManager"):
		FireManager.fire_started.connect(_on_firedrill_started)
		FireManager.fire_ended.connect(_on_firedrill_ended)
		
	# --- 3. NEW: Connect the Fire Button signal ---
	if _firedrill_button:
		_firedrill_button.pressed.connect(_on_firedrill_confirm_pressed)

	# --- 4. Level Loading Logic ---
	if day_data != null and _is_day_data_resource(day_data):
		TaskManager.start_level(day_data)
	else:
		var fallback_day = load("res://assets/days/w0day0.tres")
		if fallback_day:
			TaskManager.start_level(fallback_day)
	
	# Initial UI updates
	_on_money_updated(TaskManager.total_money)
	_update_level_clock()
	_lunch_banner.visible = false
	_lunch_confirm_button.pressed.connect(_on_lunch_confirm_pressed)
	_summary_panel.visible = false
	_firedrill_banner.visible = false

func _process(_delta: float) -> void:
	_update_level_clock()
	
	# --- 5. Automatic Fire Drill Trigger (Only trigger ONCE) ---
	if not fire_drill_triggered_today and TaskManager.level_time_passed >= 10:
		if FireManager.current_state == FireManager.FireState.NORMAL:
			fire_drill_triggered_today = true # Mark as done so it doesn't loop
			FireManager.trigger_fire_drill()
			_firedrill_banner.visible = true

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
	_money_label.text = str(new_total)


func _on_nav_requested(instance_id: String) -> void:
	var inst: TaskInstance = TaskManager.get_instance(instance_id)
	if not inst: return
	var found_path: String = inst.scene_path
	if found_path != "" and ResourceLoader.exists(found_path):
		var scene = load(found_path)
		var task_ui = scene.instantiate()
		add_child(task_ui)


func _on_lunch_started() -> void:
	_lunch_banner.visible = true

func _on_lunch_ended() -> void:
	_lunch_banner.visible = false

func _on_lunch_acknowledged() -> void:
	_lunch_banner.visible = false

func _on_lunch_confirm_pressed() -> void:
	TaskManager.acknowledge_lunch_message()
	_lunch_banner.visible = false


# --- Firedrill UI Logic ---

func _on_firedrill_started() -> void:
	if _firedrill_banner:
		_firedrill_banner.visible = true

func _on_firedrill_ended() -> void:
	if _firedrill_banner:
		_firedrill_banner.visible = false

func _on_firedrill_acknowledged() -> void:
	if _firedrill_banner:
		_firedrill_banner.visible = false

func _on_firedrill_confirm_pressed() -> void:
	# 1. Stop the alarm and red modulation
	#FireManager.stop_fire()
	# 2. Hide the banner
	_firedrill_banner.visible = false
	print("Firedrill UI closed by player.")


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
				# DEBUG: Manual trigger for the demo
				FireManager.trigger_fire_drill()
			KEY_G:
				# DEBUG: Manual stop
				FireManager.stop_fire()
