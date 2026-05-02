extends PanelContainer

signal SELECTED(index)

@onready var choices_list: VBoxContainer = $"MarginContainer/Choices"
@onready var choices_prefab: Button = $"MarginContainer/Choices/ChoiceButton"


var choices = []:
	set(value):
		choices = value
		init_button()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	choices_list.get_child(0).pressed.connect(on_choice.bind(0))


func init_button():
	var button 
	
	while choices_list.get_child_count() > 1:
		button = choices_list.get_child(choices_list.get_child_count() -1)
		choices_list.remove_child(button)
		button.queue_free()
	
	for choice_index in range(choices.size()):
		if (choice_index == 0):
			choices_list.get_child(0).text = choices[choice_index]
		else:
			choices_list.add_child(choices_prefab.duplicate())
			choices_list.get_child(choice_index).text = choices[choice_index]
			choices_list.get_child(choice_index).pressed.connect(on_choice.bind(choice_index))
	
func on_choice(choice_index):
	visible = false
	SELECTED.emit(choice_index)
