extends Panel

@onready var document_app: Button = $"Document app"
@onready var document_window: Window = $"Document app/DocumentWindow"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	document_window.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_document_window_close_requested() -> void:
	document_window.hide()


func _on_document_app_pressed() -> void:
	document_window.show()
