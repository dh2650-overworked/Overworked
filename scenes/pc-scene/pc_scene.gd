extends Control

@onready var mouse_cursor: Sprite2D = $MouseCursor
var pc_mouse_pos:Vector2 = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load the texture from your sprite's texture
	var cursor_texture = mouse_cursor.texture
	 # Set it as the custom cursor
	Input.set_custom_mouse_cursor(cursor_texture)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func update_cursor_pos(): 
	mouse_cursor.position = pc_mouse_pos 
