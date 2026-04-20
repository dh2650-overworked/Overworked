extends CanvasLayer
class_name BaseTask

signal task_completed(success: bool)

@export var task_id: String = "" # Corresponding to the Task ID in .tres

@onready var success_overlay = $SuccessOverlay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	success_overlay.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func complete_task():
	success_overlay.visible = true
	success_overlay.scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(success_overlay, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK)
	
	if task_id != "":
		TaskManager.complete_task_by_type(task_id) 
		
	await get_tree().create_timer(2.0).timeout
	
	task_completed.emit(true) 
	queue_free()

func _on_exit_button_pressed():
	task_completed.emit(false) 
	queue_free()
