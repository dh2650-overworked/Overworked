extends TextureButton

@onready var _pos_list: Array[Vector2] = [Vector2(0,0), Vector2(230,80), Vector2(120,40), Vector2(260,160)]
@onready var _rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	var val = _pos_list[_rng.randi_range(0,_pos_list.size()-1)]
	print(val)
	self.position = val
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if button_pressed && get_parent().has_placed_empty_tank:
		get_parent().has_tank = true
		disabled = true
		hide()
		
