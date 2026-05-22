extends CanvasLayer

@export var _tutorialtext: String = "1. Remove the empty watertank 
2. Place down the watertank \n 3. Find replacment watertank 
4. Place replacment on watercooler"
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	_match_current_state(WatercoolerManager.current_state)
	pass # Replace with function body.

func get_tutorial_text():
	return _tutorialtext

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#TODO: Add a listener to a node in the scene that updates the state from TANKREMOVED to TANKFOUND
	match WatercoolerManager.current_state:
		WatercoolerManager.State.TANKREMOVED:
			WatercoolerManager.current_state = WatercoolerManager.State.TANKFOUND
			$Control/PanelContainer/TextureButton.disabled = false
			$Control/PanelContainer/Label.text = "Place the watertank"
	pass

func _on_texture_button_pressed() -> void:
	match WatercoolerManager.current_state:
		WatercoolerManager.State.FRESH:
			$Control/PanelContainer/TextureButton.texture_normal = load("res://assets/tasks/Watercooler/Watercooler_tankless.png")
			$Control/PanelContainer/TextureButton.disabled = true
			$Control/PanelContainer/Label.text = "Find a new watertank"
			WatercoolerManager.current_state = WatercoolerManager.State.TANKREMOVED
		WatercoolerManager.State.TANKFOUND:
			$Control/PanelContainer/TextureButton.texture_normal = load("res://assets/tasks/Watercooler/Watercooler.png")
			$Control/PanelContainer/TextureButton.disabled = true
			TaskManager.complete_task_by_type("water_cooler")
		
			#Trigger completion and close window automatically
			var root_container = _find_canvas_layer(self)
			await get_tree().create_timer(1).timeout
			
			WatercoolerManager.current_state = WatercoolerManager.State.FRESH
			
			if root_container:
				if root_container.get_parent() == root_container.get_tree().root: 
					root_container.queue_free()
				elif root_container.get_parent().get_parent() is CanvasLayer:
					root_container.get_parent().get_parent().queue_free()
			else:
				queue_free()
			
	pass # Replace with function body.
	
func _match_current_state(current_state):
	match current_state:
		WatercoolerManager.State.FRESH:
			$Control/PanelContainer/Label.text = "Remove the watertank"
			$Control/PanelContainer/TextureButton.texture_normal = load("res://assets/tasks/Watercooler/Watercooler.png")
			$Control/PanelContainer/TextureButton.disabled = false
		WatercoolerManager.State.TANKREMOVED:
			$Control/PanelContainer/TextureButton.texture_normal = load("res://assets/tasks/Watercooler/Watercooler_tankless.png")
			$Control/PanelContainer/TextureButton.disabled = true
			$Control/PanelContainer/Label.text = "Find a new watertank"
		WatercoolerManager.State.TANKFOUND:
			$Control/PanelContainer/TextureButton.texture_normal = load("res://assets/tasks/Watercooler/Watercooler_tankless.png")
			$Control/PanelContainer/TextureButton.disabled = false
			$Control/PanelContainer/Label.text = "Place the watertank"
	

func _find_canvas_layer(node: Node) -> Node:
	var current = node
	while current != null:
		if current is CanvasLayer:
			return current
		current = current.get_parent()
	return null
