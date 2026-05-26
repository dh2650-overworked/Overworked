extends Control

@onready var mouse_cursor = load("uid://bj2dyhdlmur3r")
var pc_mouse_pos:Vector2 = Vector2.ZERO
@onready var click_sound: AudioStreamPlayer = $"../ClickSound"
@onready var pc_clock_label: Label = $TaskbarPanel/TimePanel/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Input.set_custom_mouse_cursor(mouse_cursor)
	
	if Signals.has_signal("level_time_changed"):
		Signals.level_time_changed.connect(_on_level_time_changed)
	
	_initialize_clock_on_load()

func _input(event: InputEvent) -> void:
	# 2. Check for Mouse 1 (Left Click)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			play_click_sound()

func play_click_sound():
	# Play the sound with a tiny bit of random pitch for realism
	if click_sound:
		click_sound.pitch_scale = randf_range(0.95, 1.05)
		click_sound.play()

func _exit_tree() -> void:
	# the cursor goes back to the default system arrow.
	Input.set_custom_mouse_cursor(null)

func _on_level_time_changed(formatted_time: String) -> void:
	if pc_clock_label:
		pc_clock_label.text = formatted_time


func _initialize_clock_on_load() -> void:
	if pc_clock_label:
		var current_hour: int = TaskManager.DAY_START_HOUR + int(TaskManager.level_time_passed / TaskManager.SECONDS_PER_GAME_HOUR)
		var hour_format = current_hour % 24
		pc_clock_label.text = "%02d:00" % hour_format


func update_cursor_pos(): 
	mouse_cursor.position = pc_mouse_pos 


func _on_email_app_icon_pressed() -> void:
	pass # Replace with function body.
