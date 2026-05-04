extends SubViewport

var has_tank = false
var has_empty_tank = false
var has_placed_empty_tank = false
var is_completed = false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_completed:
		TaskManager.complete_task_by_type("water_cooler")
		#Todo: Trigger completion and close window automatically
		#pass
		var root_container = _find_canvas_layer(self)
		
		await get_tree().create_timer(1).timeout
		
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
