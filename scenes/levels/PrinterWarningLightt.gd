extends Sprite2D

@export var flash_speed: float = 8.0 # Speed of flashing
var is_flashing: bool = false
var time_passed: float = 0.0

func _ready():
	self.visible = false
	PrinterManager.state_changed.connect(_on_printer_state_changed)
	_update_state(PrinterManager.current_state)

func _process(delta):
	# If the printer is jammed, make the light flicker
	if is_flashing:
		time_passed += delta * flash_speed
		# Using a sine wave or modulo for a simple blink effect
		self.visible = (int(time_passed) % 2 == 0)

func _on_printer_state_changed(new_state):
	_update_state(new_state)

func _update_state(state):
	# The light only flashes when the state is JAMMED
	if state == PrinterManager.State.JAMMED:
		is_flashing = true
	else:
		is_flashing = false
		self.visible = false # Turn off the light if not jammed
