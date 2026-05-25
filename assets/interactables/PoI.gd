@tool
extends StaticBody2D

@onready var interactable: Area2D = $Interactable
@onready var sprite_2d: Sprite2D = $Sprite2D
var scene

# @tool allows setting of exported variables
@export var sprite: Texture2D = load("res://assets/interactables/PoI.png"):
	set(value):
		sprite = value
		if has_node("Sprite2D"):
			$Sprite2D.texture = value

@export var collider: Shape2D = RectangleShape2D.new():
	set(value):
		collider = value
		if has_node("CollisionShape2D"):
			$CollisionShape2D.shape = value

@export var area: Shape2D = CapsuleShape2D.new():
	set(value):
		area = value
		if has_node("Interactable/CollisionShape2D"):
			$Interactable/CollisionShape2D.shape = value

@export var scene_path: String = "":
	set(value):
		scene_path = value	
		scene = load(scene_path)

@export var interact_name: String = "":
	set(value):
		interact_name = value
		if has_node("Interactable"):
			$Interactable.interact_name = interact_name

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return # Don't wire up game logic in editor
	
	interactable.interact = _on_interact

func _on_interact():
	if scene:
		print(scene_path)
		print("Opening:" + interact_name)
		if scene_path == "res://scenes/pc/pc_scene.tscn":
			get_tree().root.add_child(scene.instantiate())
		else:
			var basetask: BaseTask = load("res://scenes/Tasks/GeneralNode/BaseTask.tscn").instantiate()
			basetask.source_poi = self
			basetask.open_task(scene_path)
			get_tree().root.add_child(basetask)
	else:
		print("Missing scene")

func disable() -> void:
	visible = false
	interactable.is_interactable = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
