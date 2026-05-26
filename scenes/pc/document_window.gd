extends Window

@onready var success_overlay = $SuccessOverlay
@onready var text_report = $TextReport
@onready var click_sound: AudioStreamPlayer = $"../../../../ClickSound"

func _ready():
	# Connect to the signal from the child node
	text_report.report_finished.connect(complete_task)
	# Ensure focus is on the input
	text_report.get_node("PlayerInput").grab_focus()

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

func complete_task():
	TaskManager.complete_task_by_type("report_writing")
	
	success_overlay.visible = true
	success_overlay.scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(success_overlay, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK)
