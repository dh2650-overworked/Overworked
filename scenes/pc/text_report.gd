extends Node2D

signal report_finished
signal progress_updated(current_text: String)

@export var green = Color("#00FF00")
@export var blue = Color("#1d75d9")
@export var red = Color("#ad2a25")
@export var gray = Color("#666666")

@onready var prompt: RichTextLabel = $TypeText
@onready var input_field: TextEdit = $PlayerInput 
var prompt_text: String = ""

func _ready():
	# Clear any placeholder editor text out entirely so it doesn't trick the script
	input_field.text = "" 
	
	#  Setup your connections
	input_field.text_changed.connect(_on_text_changed)
	
	# Wait 1 frame here FIRST so the RichTextLabel settles its sizes ---
	await get_tree().process_frame
	
	# Match the TextEdit size to the RichTextLabel size for perfect wrapping
	input_field.custom_minimum_size = prompt.get_size()
	
	# Now shout out to main.gd to load the string data
	Signals.emit_signal("text_report_ready", self)

# This is what main.gd calls!
func setup_report(new_text: String, saved_progress: String = "") -> void:
	prompt_text = new_text
	prompt.text = new_text
	await get_tree().process_frame
	if input_field:
		# Explicitly force the input field to match the exact string main.gd passed back
		input_field.text = saved_progress
		input_field.grab_focus()
		input_field.set_caret_column(saved_progress.length())
	
	# Update the colors to paint everything green up to our saved mark
	update_display(saved_progress.length())

func _on_text_changed():
	var new_text = input_field.text
	
	if prompt_text == "": 
		return

	if prompt_text.begins_with(new_text):
		update_display(new_text.length())
		progress_updated.emit(new_text)
		
		if new_text == prompt_text:
			# Clean out the UI text immediately
			prompt_text = ""
			prompt.text = ""
			input_field.text = ""
			
			# Emit the signal up to main.gd
			report_finished.emit()
	else:
		input_field.text = new_text.substr(0, new_text.length() - 1)
		input_field.set_caret_column(input_field.text.length())

func update_display(index: int):
	var green_part = get_tag(green) + prompt_text.substr(0, index) + "[/color]"
	var blue_part = ""
	var red_part = ""
	var gray_part = ""
	if index < prompt_text.length():
		blue_part = get_tag(blue) + prompt_text.substr(index, 1) + "[/color]"
		var rest = prompt_text.substr(index + 1)
		var space_pos = rest.find(" ")
		if space_pos == -1:
			red_part = get_tag(red) + rest + "[/color]"
		else:
			red_part = get_tag(red) + rest.substr(0, space_pos) + "[/color]"
			gray_part = get_tag(gray) + rest.substr(space_pos) + "[/color]"
	prompt.text = green_part + blue_part + red_part + gray_part

func get_tag(c: Color) -> String:
	return "[color=#" + c.to_html(false) + "]"
