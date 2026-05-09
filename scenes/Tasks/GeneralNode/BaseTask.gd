extends CanvasLayer
class_name BaseTask

signal task_completed(success: bool)

@export var task_id: String = "" # Corresponding to the Task ID in .tres

@onready var success_overlay = $SuccessOverlay
@onready var tutorial_control = $TutorialControl
@onready var tutorial_overlay = $TutorialControl/TutorialOverlay
@onready var tutorial_label = $TutorialControl/TutorialOverlay/Label
@onready var tutorial_text: String = ""



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	success_overlay.visible = false
	tutorial_overlay.visible = false

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

func open_task(path: String):
	$GameContent.add_child(load(path).instantiate())

func get_tutorial_text() -> String:
	if $GameContent.get_child(0).has_method("get_tutorial_text"):
		tutorial_text = $GameContent.get_child(0).get_tutorial_text()
	else:
		tutorial_text = "Missing tutorial text"
	return tutorial_text
	
func _on_exit_button_pressed():
	task_completed.emit(false) 
	queue_free()


func _on_tutorial_button_pressed() -> void:
	tutorial_label.text = get_tutorial_text()
	tutorial_overlay.move_to_front()
	if !tutorial_overlay.visible:
		tutorial_overlay.visible = true
	else: 
		tutorial_overlay.visible = false
