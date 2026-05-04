extends TextureButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if button_pressed:
		hide()
		Input.set_custom_mouse_cursor(load("res://assets/tasks/Whiteboard/EraserSmall.png"))
		get_parent().node.has_eraser()
		
		
