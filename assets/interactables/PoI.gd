@tool
extends StaticBody2D

@onready var interactable: Area2D = $Interactable
@onready var sprite_2d: Sprite2D = $Sprite2D

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

@export var scene: PackedScene:
	set(value):
		scene = value

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
	# Apply exported values now that nodes exist
	#$Sprite2D.texture = sprite
	#$CollisionShape2D.shape = collider
	#$Interactable/CollisionShape2D.shape = area

func _on_interact():
	print(scene)
	print("Opening task")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
