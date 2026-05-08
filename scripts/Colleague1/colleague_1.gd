extends CharacterBody2D

# --- 1. Teammate's Exported Variables ---
@export var dialogue_scene: PackedScene 
@export var report_task: Resource       
@export var run_speed: float = 180.0    # Speed when fleeing the fire
var player_in_range = false

# --- 2. Fire & Panic Logic ---
var is_fleeing: bool = false
var exit_target: Vector2 = Vector2.ZERO

# --- 3. Your Overhead Dialogue Settings ---
var random_lines = [
	"Deadline is coming, move it!",
	"Why are you just standing there?",
	"The boss is watching...",
	"Did you finish that report?"
]

@onready var speech_label = $Label 
@onready var sprite = $Kevin # Reference to the static image

func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)
	
	# Listen to PrinterManager
	PrinterManager.state_changed.connect(_on_printer_changed)
	
	# --- NEW: Listen for FIRE (Assuming you have a FireManager or similar) ---
	# For testing, you can call start_fleeing(Vector2(2000, 300)) manually
	# FireManager.fire_started.connect(func(): start_fleeing(Vector2(2000, 300)))
	await get_tree().create_timer(3.0).timeout
	start_fleeing(Vector2(600, 600))
	
	if speech_label:
		speech_label.visible = false

# --- NEW: Movement logic during fire ---
func _physics_process(_delta):
	if is_fleeing:
		var direction = global_position.direction_to(exit_target)
		velocity = direction * run_speed
		
		# Flip sprite to look where they are running
		sprite.flip_h = (direction.x < 0)
		
		move_and_slide()
		
		# If they reach the exit (close to target), remove them from the world
		if global_position.distance_to(exit_target) < 20.0:
			queue_free()

# --- NEW: Trigger the Panic ---
func start_fleeing(target_pos: Vector2):
	if is_fleeing: return # Already running
	
	is_fleeing = true
	exit_target = target_pos
	
	# Stop all talking
	if speech_label:
		speech_label.text = "FIRE! RUN FOR YOUR LIVES!!!"
		speech_label.modulate = Color.ORANGE_RED
		speech_label.visible = true
	
	# Start the squash-and-stretch bounce animation for static sprite
	animate_panic_bounce()

# --- NEW: Visual effect for static sprites ---
func animate_panic_bounce():
	var tween = create_tween().set_loops()
	# Squash and stretch (Bouncing up and down)
	tween.tween_property(sprite, "scale", Vector2(1.2, 0.8), 0.1) # Flatten
	tween.tween_property(sprite, "scale", Vector2(0.8, 1.2), 0.1) # Stretch
	
	# Add a frantic rotation wobble
	var rot_tween = create_tween().set_loops()
	rot_tween.tween_property(sprite, "rotation_degrees", 15.0, 0.08)
	rot_tween.tween_property(sprite, "rotation_degrees", -15.0, 0.08)

# --- Your Logic: Printer Jam ---
func _on_printer_changed(new_state):
	if is_fleeing: return # Don't care about printer if on fire
	if speech_label:
		if new_state == PrinterManager.State.JAMMED:
			speech_label.text = "I HEAR THE PRINTER JAMMING! FIX IT NOW!"
			speech_label.modulate = Color.RED
			speech_label.visible = true
		else:
			speech_label.modulate = Color.WHITE
			speech_label.visible = false

func _on_body_entered(body: Node2D) -> void:
	if is_fleeing: return # Can't talk while running
	if body.is_in_group("player"):
		player_in_range = true
		if speech_label and PrinterManager.current_state != PrinterManager.State.JAMMED:
			speech_label.text = random_lines.pick_random()
			speech_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if speech_label: speech_label.visible = false

# --- Interaction Logic (Press E) ---
func _input(event: InputEvent) -> void:
	if is_fleeing: return # Interaction disabled during fire
	if player_in_range and event.is_action_pressed("interact"):
		if not get_tree().root.has_node("DialogueUI"):
			start_dialogue()

func start_dialogue():
	var ui = dialogue_scene.instantiate()
	ui.name = "DialogueUI"
	get_tree().root.add_child(ui)
	ui.choice_accepted.connect(func(): _on_task_accepted(ui))
	ui.choice_rejected.connect(func(): _on_task_rejected(ui))
	if speech_label: speech_label.visible = false

func _on_task_accepted(ui):
	if report_task is TaskData:
		TaskManager.add_task(report_task as TaskData, true)
	ui.show_feedback("Thank you! See you later!")
	await ui.tree_exited
	queue_free()

func _on_task_rejected(ui):
	ui.show_feedback("Oh, I see...")
