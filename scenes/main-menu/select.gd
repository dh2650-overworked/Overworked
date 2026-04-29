extends Button

var scene

func _ready():
	#if Engine.is_editor_hint():
		#return # Don't wire up game logic in editor
	var button = Button.new()
	button.pressed.connect(_button_pressed)
	add_child(button)


func _button_pressed():
	$"..".visible = false
	
	if $"..".name == "dayselect":
		$"../../mainmenu".visible = true
	if $"..".name == "mainmenu":
		$"../../dayselect".visible = true
		
	
	
