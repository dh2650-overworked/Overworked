extends Control

@onready var mouse_cursor = load("uid://bj2dyhdlmur3r")
var pc_mouse_pos:Vector2 = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = false
	#anchor_left = 0.0
	#anchor_top = 0.0
	#anchor_right = 1.0
	#anchor_bottom = 1.0
	#offset_left = 0
	#offset_top = 0
	#offset_right = 0
	#offset_bottom = 0
	
	# Load the texture from your sprite's texture
	 # Set it as the custom cursor
	Input.set_custom_mouse_cursor(mouse_cursor)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
	
	
func update_cursor_pos(): 
	mouse_cursor.position = pc_mouse_pos 


func _on_email_app_icon_pressed() -> void:
	pass # Replace with function body.
	
# 只要这个 UI 节点消失（被销毁），就强制恢复玩家移动
func _exit_tree() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = true
