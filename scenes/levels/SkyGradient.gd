extends TextureRect

var Skycolor = GradientTexture1D.new()
var scrollspeed:float = float(1)/200
const START_TIME: float = 200.0 #Set this to reasonable value for how fast a day is
# At 1/480 We get to black background at the end of the day, at 1/540 we have mostly red and 1/600 is orange with a hint of red

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Skycolor.gradient = Gradient.new()
	Skycolor.gradient.set_color(0, Color.BLACK)
	Skycolor.gradient.set_offset(0, 0)
	Skycolor.gradient.set_color(1, Color(0.702, 0.177, 0.254))
	Skycolor.gradient.set_offset(1, 0.10)
	Skycolor.gradient.add_point(0.3, Color(1.072, 0.459, 0.264))
	Skycolor.gradient.add_point(0.5, Color(0.263, 0.502, 0.992))
	Skycolor.gradient.add_point(0.75, Color(0.0, 0.535, 0.929))
	Skycolor.gradient.add_point(0.8, Color(0.11, 0.384, 0.921))
	Skycolor.gradient.add_point(0.9, Color.BLACK)
	texture = Skycolor



	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if TaskManager.level_time_passed < START_TIME:
		return
	#print(scrollspeed)
	for point in range(Skycolor.gradient.get_point_count()):
		var current_offset = Skycolor.gradient.get_offset(point)
		var movement = scrollspeed * delta
		
		if current_offset + movement < 1.0:
			Skycolor.gradient.set_offset(point, current_offset + movement)
		else:
			Skycolor.gradient.set_offset(point, current_offset + movement - 1.0)
