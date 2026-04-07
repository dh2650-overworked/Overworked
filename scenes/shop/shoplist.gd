extends ItemList

@export var money = 0
var itemlist = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	money = 2 #TODO: Update money to player money
	itemlist = get_item_list()
	for item in itemlist:
		#print(item.get_icon_path())
		add_item(item.get_name(), load(item.get_icon_path()))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func get_item_list():
	var file = FileAccess.open("res://scenes/shop/ItemListInText.txt", FileAccess.READ)
	var content = file.get_as_text()
	var item_rows = str(content).split("\n")
	if item_rows.size() > 1:
		var li = item_rows.slice(1, -1)
		for item in li:
			var split_item = item.split(",")
			for i in range(split_item.size()):
				split_item[i] = split_item[i].trim_prefix(" ")
			itemlist.append(Item_class.new(split_item[0], int(split_item[1]), split_item[2], split_item[3]))
		return itemlist
	return []

func get_shop_item_from_index(index):
	return itemlist[index]

	
	
