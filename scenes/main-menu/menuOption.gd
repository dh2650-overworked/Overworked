extends Button

var scene

@export var reset_progress_on_press: bool = false

@export var scene_path: String = "":
	set(value):
		scene_path = value	
		scene = load(scene_path)

func _ready():
	#if Engine.is_editor_hint():
		#return # Don't wire up game logic in editor
	$".".pressed.connect(_button_pressed)
	#add_child(button)


func _button_pressed():
	if reset_progress_on_press:
		TaskManager.reset_for_new_game()
		PrinterManager.reset_for_new_game()
	if scene:
		print("Opening: " + scene_path)
		get_tree().change_scene_to_node(scene.instantiate())
	else:
		print("Missing scene")
