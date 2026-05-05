extends Control

@onready var node = $Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var size: Vector2 = get_global_rect().size
	var offset: Vector2 = get_global_rect().position
	var img: Image = get_parent().get_texture().get_image()
	var winpercentage:float = 0.015
	var diff:float = 0
	var total:float = size[0]*size[1]
	for i in range(size[0]):
		for j in range(size[1]):
			if !img.get_pixel(offset[0] + i, offset[1] + j).is_equal_approx(Color.WHITE):
				diff +=1
	#print(float(diff/total))
	if winpercentage>float(diff/total):
		print("win")
		Input.set_custom_mouse_cursor(load("res://assets/icons/cursor.pngw"))
		TaskManager.complete_task_by_type("whiteboard")
		var root_container = _find_canvas_layer(self)
		
		if root_container:
			root_container.queue_free()
		else:
			queue_free()
		#queue_free()
		#pass #Trigger win

func _find_canvas_layer(node: Node) -> Node:
	var current = node
	while current != null:
		if current is CanvasLayer:
			return current
		current = current.get_parent()
	return null
