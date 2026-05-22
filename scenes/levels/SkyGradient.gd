extends TextureRect

var Skycolor = GradientTexture1D.new()
var scrollspeed:float = float(1)/(TaskManager.LEVEL_DURATION_SECONDS*2)
const START_TIME: float = 0 #Set this to reasonable value for how fast a day is

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Skycolor.gradient = Gradient.new()
	Skycolor.gradient.set_color(0, Color.BLACK)
	Skycolor.gradient.set_offset(0, 0.2)
	Skycolor.gradient.set_color(1, Color(0.702, 0.177, 0.254))
	Skycolor.gradient.set_offset(1, 0.25)
	Skycolor.gradient.add_point(0.30, Color(1.072, 0.459, 0.264))
	Skycolor.gradient.add_point(0.45, Color(0.263, 0.502, 0.992))
	Skycolor.gradient.add_point(0.65, Color(0.0, 0.535, 0.929))
	Skycolor.gradient.add_point(0.8, Color(0.11, 0.384, 0.921))
	Skycolor.gradient.add_point(0.88, Color(1.072, 0.459, 0.264))
	Skycolor.gradient.add_point(0.95, Color(0.702, 0.177, 0.254))
	Skycolor.gradient.add_point(0.99, Color.BLACK)
	texture = Skycolor

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if TaskManager.level_time_passed < START_TIME:
		return

	var all_at_end := true
	for point in range(Skycolor.gradient.get_point_count()):
		var current_offset: float = Skycolor.gradient.get_offset(point)
		if current_offset >= 1.0:
			continue
		all_at_end = false
		Skycolor.gradient.set_offset(point, minf(current_offset + scrollspeed * delta, 1.0))

	if all_at_end:
		set_process(false)
