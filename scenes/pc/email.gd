extends Node2D

@onready var email_choices: PanelContainer = $EmailChoices
# Adjust this path if your EmailWindow node structure is different
@onready var email_window: Window = $".." 

func _ready() -> void:
	email_choices.SELECTED.connect(_on_email_choice_selected)
	
	# Wait 1 frame for the scene tree to settle, then broadcast the request
	await get_tree().process_frame
	Signals.emit_signal("request_day_config", self)

func setup_email_day(day_key: String) -> void:
	print("EMAIL.GD: Dynamically loading layout configuration for: ", day_key)
	load_email_day(day_key)

func load_email_day(day_key: String):
	var file_path = "res://data/email.json"
	
	if not FileAccess.file_exists(file_path):
		print("JSON file not found!")
		return

	# Read and Parse JSON
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_helper = JSON.new()
	var parse_result = json_helper.parse(file.get_as_text())
	
	if not parse_result == OK:
		print("JSON Parse Error: ", json_helper.get_error_message())
		return

	var data = json_helper.get_data()
	
	# Safety check: ensure the day key actually exists inside email.json
	if not data.has(day_key):
		print("ERROR: email.json is missing a block for day key: ", day_key)
		return
		
	var day_data_block = data[day_key]

	# Extract and Shuffle
	var options = day_data_block["options"].duplicate()
	var correct_string = day_data_block["correct_answer"]
	
	options.shuffle() # Randomizes the order

	# Find the new index of the correct answer
	var new_correct_index = options.find(correct_string)

	# Update the UI
	email_choices.choices = options
	email_choices.correct_choice_index = new_correct_index
	email_choices.visible = true

func _on_email_choice_selected(index: int):
	# Check if they picked the right choice
	if index == email_choices.correct_choice_index:
		# Clear the task from TaskManager's active to-do list
		TaskManager.complete_task_by_type("respond_email") 
		
		# Tell the window to display the success animation/overlay
		if has_node("..") and $".." is Window:
			$"..".complete_task()
		elif email_window:
			email_window.complete_task()
	else:
		print("Wrong choice selected. Dialog remains open.")
