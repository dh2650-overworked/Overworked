extends CharacterBody2D

# --- 1. Teammate's Exports ---
@export var dialogue_scene: PackedScene
@export var report_task: Resource
var player_in_range = false

# --- 2. Your Added Logic (Lines & Label) ---
var lines = [
	"Deadline is coming, move it!",
	"Why are you just standing there?",
	"The boss is watching...",
	"Did you finish that report?"
]
@onready var dialog_label = $Label # Ensure the Label node exists in the scene!

func _ready() -> void:
	# Teammate's signal connections (using the child InteractionArea)
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)
	
	# --- Your Logic: Listen to PrinterManager ---
	PrinterManager.state_changed.connect(_on_printer_changed)
	if dialog_label:
		dialog_label.visible = false

# --- Your Logic: Handling the Printer Jam ---
func _on_printer_changed(new_state):
	if dialog_label:
		if new_state == PrinterManager.State.JAMMED:
			dialog_label.text = "I HEAR THE PRINTER JAMMING! FIX IT NOW!"
			dialog_label.modulate = Color.RED
			dialog_label.visible = true
		else:
			dialog_label.modulate = Color.WHITE
			dialog_label.visible = false

# --- Combined Logic: Player Entering ---
func _on_body_entered(body: Node2D) -> void:
	# Use teammate's group-based check (better than names)
	if body.is_in_group("player"):
		player_in_range = true
		
		# Your Logic: Show random line when player gets close
		if dialog_label and PrinterManager.current_state != PrinterManager.State.JAMMED:
			dialog_label.text = lines.pick_random()
			dialog_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		
		# Your Logic: Hide label when player walks away
		if dialog_label:
			dialog_label.visible = false

# --- Teammate's Logic: Press E to Talk ---
func _input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		if not get_tree().root.has_node("DialogueUI"):
			start_dialogue()

func start_dialogue():
	var ui = dialogue_scene.instantiate()
	ui.name = "DialogueUI"
	get_tree().root.add_child(ui)
	
	# Connect to teammate's UI signals (keep their system working)
	if ui.has_signal("choice_accepted"):
		ui.choice_accepted.connect(func(): _on_task_accepted(ui))
	if ui.has_signal("choice_rejected"):
		ui.choice_rejected.connect(func(): _on_task_rejected(ui))

# --- Keep teammate's task functions at the bottom ---
func _on_task_accepted(ui):
	if report_task is TaskData:
		TaskManager.add_task(report_task as TaskData, true)
	ui.show_feedback("Thank you! See you after the wedding!")
	await ui.tree_exited
	queue_free()

func _on_task_rejected(ui):
	ui.show_feedback("Oh, I see... I'll have to cancel my plans.")
