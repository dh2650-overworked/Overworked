extends CanvasLayer

signal choice_accepted
signal choice_rejected

@onready var name_label = $Control/NameTag 
@onready var content_label = $Control/MarginContainer/PanelContainer/VBoxContainer/ContentText
@onready var button_container = $Control/MarginContainer/PanelContainer/VBoxContainer/HBoxContainer

func setup_dialogue(speaker_name: String, dialogue_text: String):
	name_label.text = speaker_name
	content_label.text = dialogue_text
	button_container.show() # Make sure the button is visible when starting.

func _on_accept_btn_pressed():
	choice_accepted.emit()
	# Waiting for colleague's script to call show_feedback

func _on_reject_btn_pressed():
	choice_rejected.emit()

# Feedback function triggered by colleague's script
func show_feedback(feedback_text: String):
	content_label.text = feedback_text
	button_container.hide() # The button disappears to prevent a second click.
	
	await get_tree().create_timer(2.0).timeout
	queue_free()
