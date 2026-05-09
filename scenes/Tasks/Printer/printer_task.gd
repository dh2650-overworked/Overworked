extends CanvasLayer

@export var _tutorialtext: String = "Click to start the printer. Beware of eventuall errors and dont leave the printer unsupervized."

# Variable to store the starting position to prevent the sprite from drifting
var original_p_pos: Vector2

@onready var p_closed = $PrinterClosed
@onready var p_open = $PrinterOpen
@onready var p_paper = $JammedPaper
@onready var label = $StatusLabel
@onready var bar = $ProgressBar

func _ready():
	# Store the original position of the sprite
	original_p_pos = p_closed.position
	
	# Connect to global signals
	PrinterManager.state_changed.connect(_on_status_changed)
	PrinterManager.progress_updated.connect(func(v): bar.value = v)
	
	# Sync UI with background state immediately upon opening
	bar.value = PrinterManager.progress
	_on_status_changed(PrinterManager.current_state)

func _process(_delta):
	# Shake effect: Only vibrate when the state is PRINTING
	if PrinterManager.current_state == PrinterManager.State.PRINTING:
		var shake_offset = Vector2(randf_range(-1.5, 1.5), randf_range(-1.5, 1.5))
		p_closed.position = original_p_pos + shake_offset
	else:
		# Reset to the exact center when not printing or when jammed
		p_closed.position = original_p_pos

func get_tutorial_text():
	return _tutorialtext

func _input(event):
	# Handle mouse interaction on the UI
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_player_click()

func handle_player_click():
	match PrinterManager.current_state:
		PrinterManager.State.IDLE:
			PrinterManager.start_load_sequence()
		PrinterManager.State.WAITING_FOR_PAPER:
			PrinterManager.insert_paper()
		PrinterManager.State.JAMMED:
			PrinterManager.fix_jam()
		PrinterManager.State.FINISHED:
			# Reset the manager AND close this UI immediately
			TaskManager.complete_task_by_type("printer")
			PrinterManager.collect_docs()
			queue_free()

func _on_status_changed(new_state):
	# Update visibility and text based on the manager state
	match new_state:
		PrinterManager.State.IDLE:
			p_closed.visible = true; p_open.visible = false; p_paper.visible = false
			label.text = "READY - CLICK TO START"
		PrinterManager.State.WAITING_FOR_PAPER:
			p_closed.visible = false; p_open.visible = true; p_paper.visible = false
			label.text = "INSERT PAPER"
		PrinterManager.State.PRINTING:
			p_closed.visible = true; p_open.visible = false; p_paper.visible = false
			label.text = "PRINTING..."
		PrinterManager.State.JAMMED:
			p_closed.visible = false; p_open.visible = true; p_paper.visible = true
			label.text = "ERROR: PAPER JAM!"
		PrinterManager.State.FINISHED:
			p_closed.visible = true; p_open.visible = false; p_paper.visible = false
			label.text = "DONE! COLLECT DOCUMENTS"

func _on_exit_button_pressed():
	queue_free()
