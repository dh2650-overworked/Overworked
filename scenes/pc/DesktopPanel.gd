extends Panel

@onready var document_app: Button = $"DocumentAppIcon"
@onready var document_window: Window = $"DocumentAppIcon/DocumentWindow"
@onready var email_app: Button = $EmailAppIcon
@onready var email_window: Window = $"EmailAppIcon/EmailWindow"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	document_window.hide()
	email_window.hide()


func _on_document_window_close_requested() -> void:
	document_window.hide()


func _on_document_app_pressed() -> void:
	document_window.show()


func _on_email_app_pressed() -> void:
	email_window.show()


func _on_email_window_close_requested() -> void:
	email_window.hide()
