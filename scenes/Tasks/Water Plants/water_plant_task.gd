extends CanvasLayer

# Signal to notify the main game when the task finishes
signal task_finished(success)

@export_group("Task Settings")
@export var grow_speed: float = 35.0      # Speed of growth
@export var target_row: int = 2           # Row in sprite sheet (2 = 3rd row)
@export var h_frames: int = 5             # Frames per row
@export var check_distance: float = 40.0 # Interaction range (Note: 30 was likely too small)
@export var _tutorialtext: String = "Press and hold left click on the plants to water the plants"

var progress: float = 0.0
var is_completed: bool = false
var is_in_range: bool = false

# Ensure these node names match your Scene Tree exactly!
@onready var plant = $Plant
@onready var progress_bar = $ProgressBar
@onready var success_overlay = $SuccessOverlay
@onready var watering_can = $WateringCan
@onready var water_sound = $WaterSound
# TODO add to taskManager instead
#@onready var success_sound = $SuccessSound # <-- NEW: Add an AudioStreamPlayer node with this name
@onready var water_particles = $WateringCan/CPUParticles2D

func _ready():
	progress = 0.0
	progress_bar.value = 0.0
	success_overlay.visible = false
	update_plant_visuals()

func _process(delta):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = false
		
	# 1. Watering can follows the mouse
	var mouse_pos = get_viewport().get_mouse_position()
	watering_can.global_position = mouse_pos

	if is_completed:
		# Cleanup sounds and visuals on completion
		if water_sound.playing: 
			water_sound.stop()
		water_particles.emitting = false
		watering_can.visible = false
		if player: player.can_move = true
		return

	# 2. Range detection
	var distance = watering_can.global_position.distance_to(plant.global_position)
	is_in_range = distance < check_distance

	# 3. Watering logic check
	var is_actually_watering = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and is_in_range

	if is_actually_watering:
		water_logic(delta)
		# Rotation animation
		watering_can.rotation = lerp_angle(watering_can.rotation, deg_to_rad(-45), 0.2)
		# Sound and particles
		if not water_sound.playing: 
			water_sound.play()
		if not water_particles.emitting: 
			water_particles.emitting = true
	else:
		# Idle state
		watering_can.rotation = lerp_angle(watering_can.rotation, 0.0, 0.2)
		if water_sound.playing: 
			water_sound.stop()
		if water_particles.emitting: 
			water_particles.emitting = false

func get_tutorial_text():
	return _tutorialtext

func water_logic(delta):
	if progress < 100.0:
		progress += grow_speed * delta
		progress_bar.value = progress
		update_plant_visuals()
		
		if progress >= 100.0:
			complete_task()

func update_plant_visuals():
	var start_frame = (target_row * h_frames) + 1
	# Use float 25.1 to avoid integer division warnings
	var frame_offset = int(progress / 25.1)
	plant.frame = start_frame + frame_offset

func complete_task():
	is_completed = true
	
	# 1. Play success sound
	#if success_sound:
		#success_sound.play()
	
	# 2. Show success UI with animation
	success_overlay.visible = true
	success_overlay.scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(success_overlay, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK)
	
	# 3. Sync with TaskManager if it exists
	if Engine.has_singleton("TaskManager"):
		get_node("/root/TaskManager").complete_task_by_type("water_plants")

	print("Task completed!")
	
	# Wait 2 seconds for player to see the result
	await get_tree().create_timer(2.0).timeout

	# 4. Notify and remove the task scene
	TaskManager.complete_task_by_type("water_plant")

	emit_signal("task_finished", false)
	if get_parent() == get_tree().root: 
		queue_free()
	elif get_parent().get_parent() is CanvasLayer:
		get_parent().get_parent().queue_free()

func _on_exit_button_pressed():
	emit_signal("task_finished", false)
	if get_parent() == get_tree().root: 
		queue_free()
	elif get_parent().get_parent() is CanvasLayer:
		get_parent().get_parent().queue_free()
