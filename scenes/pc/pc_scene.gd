extends Control

@onready var mouse_cursor = load("uid://bj2dyhdlmur3r")
var pc_mouse_pos:Vector2 = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
	
	# Load the texture from your sprite's texture
	 # Set it as the custom cursor
	Input.set_custom_mouse_cursor(mouse_cursor)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func update_cursor_pos(): 
	mouse_cursor.position = pc_mouse_pos 
