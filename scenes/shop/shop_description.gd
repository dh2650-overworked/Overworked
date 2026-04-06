extends RichTextLabel

var parent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = "Descriptions go here"
	parent = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var items = get_parent().get_selected_items()
	var val = ""
	if !items.is_empty():
		val = str(parent.get_shop_item_from_index(parent.get_selected_items()[0]).get_desc())
	text = val
