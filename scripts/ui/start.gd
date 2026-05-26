extends CanvasLayer

# Notify the main scene after the animation finishes playing
signal cinematic_finished 
signal overtime_choice_made(accepted: bool)
signal request_next_level(scene_path: String)

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _start_dim: ColorRect = $StartDim
@onready var _alarm_sound: AudioStreamPlayer = $AlarmSound

@onready var _overtime_panel: Control = $OvertimePanel
@onready var _game_over_panel: Control = $"Game over"
@onready var _day_label: Label = $StartDim/DayLabel
@onready var _blank_line: Label = $SummaryPanel/MarginContainer/Stats/BlankLine
@onready var _warning_label: Label = $SummaryPanel/MarginContainer/Stats/WarningLabel
@onready var _next_level_button: Button = $SummaryPanel/MarginContainer/Buttons/NextLevelButton
@onready var _replay_button: Button = $SummaryPanel/MarginContainer/Buttons/ReplayButton

func _ready() -> void:
	if _overtime_panel:
		_overtime_panel.visible = false
	if _game_over_panel:
		_game_over_panel.visible = false
	configure_summary(true)

# 3. public function for main.gd
func play_start_of_day_cinematic(day_label: String = "") -> void:
	
	_start_dim.visible = true
	_start_dim.modulate.a = 1.0
	_alarm_sound.volume_db = -15.0
	_alarm_sound.play()
	
	if _day_label:
		_day_label.text = day_label
		_day_label.visible = not day_label.is_empty()
	
	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(_alarm_sound, "volume_db", -80.0, 0.5)
	
	if _animation_player.has_animation("start_of_day"):
		_animation_player.play("start_of_day")
		await _animation_player.animation_finished
	else:
		push_warning("An animation named ‘start_of_day’ was not found in AnimationPlayer.")

	_start_dim.visible = false
	_alarm_sound.stop()
	cinematic_finished.emit()

func show_overtime_prompt() -> void:
	if _overtime_panel:
		_overtime_panel.visible = true
		print("UI: Unfinished tasks have been detected,OvertimePanel will pop up")
	else:
		push_error("UI: didn't find OvertimePanel！")


func hide_overtime_prompt() -> void:
	if _overtime_panel:
		_overtime_panel.visible = false


func show_game_over() -> void:
	if _overtime_panel:
		_overtime_panel.visible = false
	if _game_over_panel:
		_game_over_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		_game_over_panel.visible = true


func configure_summary(met_daily_goal: bool) -> void:
	var show_failed := not met_daily_goal
	if _blank_line:
		_blank_line.visible = show_failed
	if _warning_label:
		_warning_label.visible = show_failed
	if _replay_button:
		_replay_button.visible = show_failed
	if _next_level_button:
		_next_level_button.visible = met_daily_goal

func _on_overtime_yes_button_pressed() -> void:
	_overtime_panel.visible = false
	overtime_choice_made.emit(true)


func _on_overtime_no_button_pressed() -> void:
	_overtime_panel.visible = false 
	overtime_choice_made.emit(false)


func _on_next_level_button_pressed() -> void:
	var path: String = str(get_meta("next_level_path")) if has_meta("next_level_path") else ""
	
	get_tree().paused = false

	if not path.is_empty() and ResourceLoader.exists(path):
		get_tree().change_scene_to_file(path)
	else:
		get_tree().reload_current_scene()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main-menu/MainMenu.tscn")


func _on_replay_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
