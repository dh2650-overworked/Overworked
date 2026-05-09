extends Node

# Define states of the fire drill
enum FireState { NORMAL, ALARM, ACTIVE, EXTINGUISHED }

var current_state = FireState.NORMAL
var fire_duration: float = 20.0 # How long the fire lasts

signal fire_started()
signal fire_ended()

# Function to trigger the event from anywhere
func trigger_fire_drill():
	if current_state == FireState.NORMAL:
		current_state = FireState.ACTIVE
		fire_started.emit()
		print("FIRE DRILL STARTED!")
		
		# Auto-end fire after some time (optional)
		await get_tree().create_timer(fire_duration).timeout
		stop_fire_drill()

func stop_fire_drill():
	current_state = FireState.NORMAL
	fire_ended.emit()
	print("Fire drill is over.")
