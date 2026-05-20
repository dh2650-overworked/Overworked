extends CanvasLayer

@export var _tutorialtext: String = "Click to pick up the watertank, you need to place it at the watercooler"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WatercoolerManager.current_state = WatercoolerManager.State.TANKREMOVED	
	match WatercoolerManager.current_state:
		WatercoolerManager.State.FRESH:
			$Control/PanelContainer/Label.text = "You need to remove the old watertank\nfrom the watercooler first"
		WatercoolerManager.State.TANKREMOVED:
			$Control/PanelContainer/Label.text = "Pick up the watertank"
		WatercoolerManager.State.TANKFOUND:
			$Control/PanelContainer/Label.text = "You are already holding a watertank"

	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_tutorial_text():
	return _tutorialtext

func _on_texture_button_pressed() -> void:
	match WatercoolerManager.current_state:
		WatercoolerManager.State.TANKREMOVED:
			WatercoolerManager.current_state = WatercoolerManager.State.TANKFOUND
			$Control/PanelContainer/TextureButton.hide()
			
			var root_container = _find_canvas_layer(self)
			await get_tree().create_timer(1).timeout			
			if root_container:
				if root_container.get_parent() == root_container.get_tree().root: 
					root_container.queue_free()
				elif root_container.get_parent().get_parent() is CanvasLayer:
					root_container.get_parent().get_parent().queue_free()
			else:
				queue_free()

func _find_canvas_layer(node: Node) -> Node:
	var current = node
	while current != null:
		if current is CanvasLayer:
			return current
		current = current.get_parent()
	return null
