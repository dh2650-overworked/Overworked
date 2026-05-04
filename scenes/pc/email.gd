extends Node2D

@onready var email_choices: PanelContainer = $EmailChoices

func _ready() -> void:
	email_choices.SELECTED.connect(_on_email_choice_selected)
	load_email_day("Monday_Week_1")

func load_email_day(day_key: String):
	var file_path = "res://data/email.json"
	
	if not FileAccess.file_exists(file_path):
		print("JSON file not found!")
		return

	# 1. Read and Parse JSON
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_helper = JSON.new()
	var parse_result = json_helper.parse(file.get_as_text())
	
	if not parse_result == OK:
		print("JSON Parse Error: ", json_helper.get_error_message())
		return

	var data = json_helper.get_data()
	var day_data = data[day_key]

	# 2. Extract and Shuffle
	var options = day_data["options"].duplicate()
	var correct_string = day_data["correct_answer"]
	
	options.shuffle() # Randomizes the order

	# 3. Find the new index of the correct answer
	var new_correct_index = options.find(correct_string)

	# 4. Update the UI
	email_choices.choices = options
	email_choices.correct_choice_index = new_correct_index
	email_choices.visible = true

func _on_email_choice_selected(index: int):
	if index == email_choices.correct_choice_index:
		print("Correct! Points added.")
	else:
		print("Wrong choice.")
