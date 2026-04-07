class_name Item_class

var _name
var _cost
var _description
var _icon_path

func _init(item_name = "Missing name", item_cost = 0, item_descript = "Missing description", item_icon_path = "res://icon.svg"):
	_name = item_name
	_cost = item_cost
	_description = item_descript
	_icon_path = item_icon_path

func get_name():
	return _name
	
func get_desc():
	return _description

func get_cost():
	return _cost
	
func get_icon_path():
	return _icon_path 
