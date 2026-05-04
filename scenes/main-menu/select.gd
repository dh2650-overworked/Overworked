extends Button

func _ready():
	$".".pressed.connect(_button_pressed)

func _button_pressed():
	$"..".visible = false
	
	if $"..".name == "dayselect":
		$"../../mainmenu".visible = true
	if $"..".name == "mainmenu":
		$"../../dayselect".visible = true
