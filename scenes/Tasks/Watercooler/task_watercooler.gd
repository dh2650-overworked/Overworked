extends CanvasLayer

@export var _tutorialtext: String = "1. Remove the empty watertank 
2. Place down the watertank \n 3. Find replacment watertank 
4. Place replacment on watercooler"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.

func get_tutorial_text():
	return _tutorialtext

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
