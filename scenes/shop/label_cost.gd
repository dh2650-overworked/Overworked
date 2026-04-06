extends Label

var parent

func _ready() -> void:
	text = "Cost: " 
	parent = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var items = get_parent().get_selected_items()
	var val = ""
	if !items.is_empty():
		val = str(parent.get_shop_item_from_index(parent.get_selected_items()[0]).get_cost()) 
	text = "Cost: " + val # Insert item cost value


func reset_cost() -> void:
	text = "Cost: "
