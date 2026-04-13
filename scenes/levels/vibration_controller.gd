extends Node

# This script lives on a separate "Logic Node" 
# and controls the Sprite2D belonging to its parent.

@onready var target_sprite = get_parent().get_node("Sprite2D")
var original_pos: Vector2

func _ready():
	if target_sprite:
		original_pos = target_sprite.position

func _process(_delta):
	if target_sprite and PrinterManager.current_state == PrinterManager.State.PRINTING:
		var offset = Vector2(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))
		target_sprite.position = original_pos + offset
	elif target_sprite:
		target_sprite.position = original_pos
