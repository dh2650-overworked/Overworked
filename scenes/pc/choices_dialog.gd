extends PanelContainer

signal SELECTED(index)

@onready var choices_list: VBoxContainer = $"MarginContainer/Choices"
@onready var choices_prefab: Button = $"MarginContainer/Choices/ChoiceButton"

var correct_choice_index: int = 0 
var choices = []:
	set(value):
		choices = value
		init_button()

func init_button():
	# Clean up previous buttons
	while choices_list.get_child_count() > 1:
		var btn_to_rem = choices_list.get_child(choices_list.get_child_count() -1)
		choices_list.remove_child(btn_to_rem)
		btn_to_rem.queue_free()
	
	for i in range(choices.size()):
		var btn: Button = choices_list.get_child(0) if i == 0 else choices_prefab.duplicate()
		if i > 0: choices_list.add_child(btn)
		
		btn.text = choices[i]
		
		# Clear any colors from previous rounds
		btn.add_theme_color_override("font_color", Color.BLACK)
		btn.add_theme_color_override("font_hover_color", Color.BLACK)
		
		# Connect signal (ensuring no duplicates)
		if btn.pressed.is_connected(on_choice):
			btn.pressed.disconnect(on_choice)
		btn.pressed.connect(on_choice.bind(i))

func on_choice(index: int):
	# 1. Stop mouse input so player can't click other buttons
	# This is better than 'disabled' because it won't gray out your colors
	for child in choices_list.get_children():
		child.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var selected_button = choices_list.get_child(index) as Button
	
	# 2. Apply the color override
	if index == correct_choice_index:
		selected_button.add_theme_color_override("font_color", Color.GREEN)
		# Optional: set hover/pressed colors too so it stays green if the mouse is over it
		selected_button.add_theme_color_override("font_hover_color", Color.GREEN)
		selected_button.add_theme_color_override("font_pressed_color", Color.GREEN)
	else:
		selected_button.add_theme_color_override("font_color", Color.RED)
		selected_button.add_theme_color_override("font_hover_color", Color.RED)
		selected_button.add_theme_color_override("font_pressed_color", Color.RED)

	# 3. Wait for feedback
	await get_tree().create_timer(0.6).timeout
	
	# 4. Clean up
	visible = false
	
	# Reset mouse filter for next time
	for child in choices_list.get_children():
		child.mouse_filter = Control.MOUSE_FILTER_STOP
		
	SELECTED.emit(index)
