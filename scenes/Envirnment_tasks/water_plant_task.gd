extends CanvasLayer

# Signal to notify the main game when the task ends
signal task_finished(success)

@export_group("Task Settings")
@export var grow_speed: float = 35.0   # How fast the progress bar fills
@export var target_row: int = 2        # Which row of the sprite sheet to use (0-indexed)
@export var h_frames: int = 5          # Number of horizontal frames in your sprite sheet

var progress: float = 0.0              # Current progress (0 to 100)
var is_completed: bool = false         # Flag to prevent multiple triggers

# Node references
@onready var plant = $Plant
@onready var progress_bar = $ProgressBar
@onready var success_overlay = $SuccessOverlay

func _ready():
	# Initialization
	progress = 0.0
	progress_bar.value = 0.0
	success_overlay.visible = false
	update_plant_visuals()

func _process(delta):
	if is_completed:
		return

	# Detect if the player is holding the Left Mouse Button
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		water_logic(delta)

func water_logic(delta):
	if progress < 100.0:
		progress += grow_speed * delta
		progress_bar.value = progress
		
		# Update plant visuals as it grows
		update_plant_visuals()
		
		# Check for completion
		if progress >= 100.0:
			complete_task()

func update_plant_visuals():
	# Logic: Skip the first frame (seed/empty), use the next 4 growth stages
	# Calculation: (Row Index * Frames per Row) + 1
	var start_frame = (target_row * h_frames) + 1
	
	# Map 0-100 progress to 0, 1, 2, 3 frame offsets
	# Using 25.1 to prevent index overflow when progress is exactly 100
	var offset = int(progress / 25.1)
	
	# Set the current frame of the Sprite2D
	plant.frame = start_frame + offset

func complete_task():
	is_completed = true
	
	# 1. Show the success UI
	success_overlay.visible = true
	
	# 2. Add a pop-up animation (Scale from 0 to 1)
	# Note: Ensure SuccessOverlay's Pivot Offset is centered
	success_overlay.scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(success_overlay, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK)

	print("Task Completed: Plant is fully grown!")
	
	# 3. Wait 2 seconds so player can see the feedback
	await get_tree().create_timer(2.0).timeout
	
	# 4. Notify and remove the task scene
	TaskManager.complete_task_by_type("water_plant")
	emit_signal("task_finished", true)
	queue_free()

# Connect this function to the "pressed" signal of your ExitButton
func _on_exit_button_pressed():
	emit_signal("task_finished", false)
	queue_free()
