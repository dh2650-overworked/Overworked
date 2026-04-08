extends SubViewport

var has_tank = false
var has_empty_tank = false
var has_placed_empty_tank = false
var is_completed = false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_completed:
		#Todo: Trigger completion and close window automatically
		pass
