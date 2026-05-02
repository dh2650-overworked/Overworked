extends Node2D

@onready var email_choices: PanelContainer = $"EmailChoices"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	email_choices.choices = ["The correct answer", "The almost correct answer", "the wrong answer"]
	email_choices.visible = true
