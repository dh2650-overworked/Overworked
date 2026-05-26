extends PanelContainer

signal SELECTED(index)

@onready var choices_list: VBoxContainer = $"MarginContainer/Choices"
@onready var choices_prefab: Button = $"MarginContainer/Choices/ChoiceButton"

var correct_choice_index: int = 0 
var is_solved: bool = false # Tracks if this minigame has been successfully completed

var choices = []:
	set(value):
		choices = value
		is_solved = false # Reset state for a brand new set of choices
		init_button()

func init_button():
	# If already solved, don't build or show anything
	if is_solved:
		visible = false
		return
		
	# Clean up previous buttons
	while choices_list.get_child_count() > 1:
		var btn_to_rem = choices_list.get_child(choices_list.get_child_count() -1)
		choices_list.remove_child(btn_to_rem)
		btn_to_rem.queue_free()
	
	for i in range(choices.size()):
		var btn: Button = choices_list.get_child(0) if i == 0 else choices_prefab.duplicate()
		if i > 0: choices_list.add_child(btn)
		
		btn.text = choices[i]
		
		# Reset default colors and interaction states
		btn.add_theme_color_override("font_color", Color.BLACK)
		btn.add_theme_color_override("font_hover_color", Color.BLACK)
		btn.add_theme_color_override("font_pressed_color", Color.BLACK)
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		
		# Connect signal (ensuring no duplicates)
		if btn.pressed.is_connected(on_choice):
			btn.pressed.disconnect(on_choice)
		btn.pressed.connect(on_choice.bind(i))

func on_choice(index: int):
	var selected_button = choices_list.get_child(index) as Button
	
	# Lock input only on the clicked button so they can't spam it while waiting
	selected_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if index == correct_choice_index:
		# Correct Answer Sequence
		is_solved = true
		selected_button.add_theme_color_override("font_color", Color.GREEN)
		selected_button.add_theme_color_override("font_hover_color", Color.GREEN)
		selected_button.add_theme_color_override("font_pressed_color", Color.GREEN)
		
		# Lock ALL buttons now because the minigame is over
		for child in choices_list.get_children():
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
		await get_tree().create_timer(0.6).timeout
		
		visible = false
		SELECTED.emit(index)
	else:
		# 2. Wrong Answer Sequence
		selected_button.add_theme_color_override("font_color", Color.RED)
		selected_button.add_theme_color_override("font_hover_color", Color.RED)
		selected_button.add_theme_color_override("font_pressed_color", Color.RED)
		
		# Give a small pause for visual feedback, then allow them to keep trying
		await get_tree().create_timer(0.4).timeout
