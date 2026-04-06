extends Button

var parent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var items = parent.get_selected_items()
	if items.is_empty() && button_pressed:
		pass 
		#print("No item selected")
	if !items.is_empty() && button_pressed:
		if parent.money >= parent.get_shop_item_from_index(items[0]).get_cost():
			print("item "+ parent.get_item_text(items[0]) +" bought")
			parent.money -= parent.get_shop_item_from_index(items[0]).get_cost()
			parent.set_item_disabled(items[0], true)
			parent.deselect_all()
		else:	
			print("not enough money")
		
