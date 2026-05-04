extends CharacterBody2D

@export var dialogue_scene: PackedScene 
@export var report_task: Resource
var player_in_range = false

func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false

func _input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		if not get_tree().root.has_node("DialogueUI"): 
			start_dialogue()

func start_dialogue():
	var ui = dialogue_scene.instantiate()
	ui.name = "DialogueUI"
	get_tree().root.add_child(ui)
	ui.setup_dialogue("Kevin", "Hey! I need to submit a report, but I’m about to head out for a wedding... 
Could you take care of it for me?")
	
	ui.choice_accepted.connect(func(): _on_task_accepted(ui))
	ui.choice_rejected.connect(func(): _on_task_rejected(ui))

func _on_task_accepted(ui):
	# NPC-granted tasks must bypass lunch guard (add_task normally no-ops while lunch_active).
	if report_task is TaskData:
		TaskManager.add_task(report_task as TaskData, true)
		print("System: Task 'report_writing' has been added to the to-do list.")
	elif report_task != null:
		push_error("Colleague report_task must be TaskData; got %s" % report_task.get_class())
	else:
		push_error("No task resources specified")
		
	# Display a thank-you message on the UI and start a 2-second countdown.
	ui.show_feedback("Thank you! You saved my life. 
See you after the wedding!")
	# Wait for the UI to disappear before making your colleague disappear.
	await ui.tree_exited
	queue_free()

func _on_task_rejected(ui):
	# The UI displays feedback after rejection.
	ui.show_feedback("Oh, I see... 
I guess I'll have to cancel my plans then.")
	# Colleagues will stay where they are
