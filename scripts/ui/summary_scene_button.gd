extends Button

## Assign a .tscn in the inspector. Empty = reload current scene (dev fallback).

# TODO surface to UI root node
@export_file("*.tscn") var target_scene_path: String = ""


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	get_tree().paused = false
	if target_scene_path.is_empty():
		get_tree().reload_current_scene()
		return
	if not ResourceLoader.exists(target_scene_path):
		push_warning("%s: scene not found: %s — reloading current scene." % [name, target_scene_path])
		get_tree().reload_current_scene()
		return
	get_tree().change_scene_to_file(target_scene_path)
