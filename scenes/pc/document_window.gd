extends Window

@onready var success_overlay = $SuccessOverlay
@onready var text_report = $TextReport

func _ready():
	# Connect to the signal from the child node
	text_report.report_finished.connect(complete_task)
	# Ensure focus is on the input
	text_report.get_node("PlayerInput").grab_focus()

func complete_task():
	TaskManager.complete_task_by_type("report_writing")
	
	success_overlay.visible = true
	success_overlay.scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(success_overlay, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK)
