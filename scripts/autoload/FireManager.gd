extends Node

# Define states of the fire drill
enum FireState { NORMAL, ALARM, ACTIVE, EXTINGUISHED }

var current_state = FireState.NORMAL
var fire_duration: float = 20.0 # How long the fire lasts

signal fire_started()
signal fire_ended()

# Function to trigger the event from anywhere
func trigger_fire_drill():
	fire_started.emit()

func stop_fire():
	fire_ended.emit()
