extends CanvasLayer

@export var _tutorialtext: String = "Pick up the eraser and make the whiteboard squeaky clean"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_tutorial_text():
	return _tutorialtext
	
# 只要这个 UI 节点消失（被销毁），就强制恢复玩家移动
func _exit_tree() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = true
