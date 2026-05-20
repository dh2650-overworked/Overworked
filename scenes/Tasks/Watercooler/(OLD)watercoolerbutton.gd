extends TextureButton

var tank_empty
var no_tank 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tank_empty = true
	no_tank = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if button_pressed && tank_empty:
		self.texture_normal = load("res://assets/tasks/Watercooler/Watercooler_tankless.png")
		tank_empty = false
		no_tank = true
		get_parent().has_empty_tank = true
	elif button_pressed && no_tank && get_parent().has_tank:
		self.texture_normal = load("res://assets/tasks/Watercooler/Watercooler.png") #TODO: replace asset with filled bottle
		disabled = true
		get_parent().is_completed = true
		#TODO: Make a declaration that the task is complete somehow
		
