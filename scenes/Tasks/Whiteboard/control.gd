extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var img: Image = get_parent().get_texture().get_image()
	var size = get_parent().size
	var winpercentage:float = 0.015
	var diff:float = 0
	var total:float = size[0]*size[1]
	for i in range(size[0]):
		for j in range(size[1]):
			if !img.get_pixel(i,j).is_equal_approx(Color.WHITE):
				diff +=1
	#print(float(diff/total))
	if winpercentage>float(diff/total):
		print("win")
		pass #Trigger win
