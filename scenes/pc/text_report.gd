extends Node2D

signal report_finished

@export var green = Color("#00FF00")
@export var blue = Color("#1d75d9")
@export var red = Color("#ad2a25")
@export var gray = Color("#666666")

@onready var prompt: RichTextLabel = $TypeText
@onready var input_field: TextEdit = $PlayerInput 
@onready var prompt_text: String = prompt.text

func _ready():
	# TextEdit signal is just 'text_changed', it doesn't pass the text string
	input_field.text_changed.connect(_on_text_changed)
	
	# Match the TextEdit size to the RichTextLabel size for perfect wrapping
	input_field.custom_minimum_size = prompt.get_size()
	
	input_field.grab_focus()
	update_display(0)

func _on_text_changed():
	var new_text = input_field.text
	
	# Check if input is correct
	if prompt_text.begins_with(new_text):
		update_display(new_text.length())
		
		if new_text == prompt_text:
			report_finished.emit()
	else:
		# If mistake: revert text and keep cursor at the end
		input_field.text = new_text.substr(0, new_text.length() - 1)
		input_field.set_caret_column(input_field.text.length())
		# Optional: Add a 'Screen Shake' or 'Buzzer' sound here

func update_display(index: int):
	var green_part = get_tag(green) + prompt_text.substr(0, index) + "[/color]"
	
	var blue_part = ""
	var red_part = ""
	var gray_part = ""
	
	if index < prompt_text.length():
		# The Blue 'Cursor' Character
		blue_part = get_tag(blue) + prompt_text.substr(index, 1) + "[/color]"
		
		var rest = prompt_text.substr(index + 1)
		var space_pos = rest.find(" ")
		
		if space_pos == -1:
			red_part = get_tag(red) + rest + "[/color]"
		else:
			# Red for the current word, Gray for the future
			red_part = get_tag(red) + rest.substr(0, space_pos) + "[/color]"
			gray_part = get_tag(gray) + rest.substr(space_pos) + "[/color]"

	prompt.text = green_part + blue_part + red_part + gray_part

func get_tag(c: Color) -> String:
	return "[color=#" + c.to_html(false) + "]"
