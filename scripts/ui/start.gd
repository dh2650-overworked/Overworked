extends CanvasLayer

# Notify the main scene after the animation finishes playing
signal cinematic_finished 
signal overtime_choice_made(accepted: bool)

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _start_dim: ColorRect = $StartDim
@onready var _alarm_sound: AudioStreamPlayer = $AlarmSound

@onready var _overtime_panel: Control = $OvertimePanel

func _ready() -> void:
	if _overtime_panel:
		_overtime_panel.visible = false

# 3. public function for main.gd
func play_start_of_day_cinematic() -> void:
	
	_start_dim.visible = true
	_start_dim.modulate.a = 1.0
	_alarm_sound.volume_db = 0.0
	_alarm_sound.play()
	
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

func _on_overtime_yes_button_pressed() -> void:
	_overtime_panel.visible = false
	overtime_choice_made.emit(true)


func _on_overtime_no_button_pressed() -> void:
	_overtime_panel.visible = false 
	overtime_choice_made.emit(false)
