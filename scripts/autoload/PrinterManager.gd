extends Node

# Define the possible states of the printer
enum State { IDLE, WAITING_FOR_PAPER, PRINTING, JAMMED, FINISHED }

# Current printer properties
var current_state = State.IDLE
var progress: float = 0.0
var jam_chance: float = 0.001 # Probability of a jam per frame

# Signals to update the UI
signal state_changed(new_state)
signal progress_updated(value)

func _process(delta: float) -> void:
	# Progress only increases while the state is PRINTING
	if current_state == State.PRINTING:
		progress += 12.0 * delta # Adjust this for printing speed
		progress_updated.emit(progress)
		
		# Randomly check for a Paper Jam
		if randf() < jam_chance:
			change_state(State.JAMMED)
			
		# Check if printing is done
		if progress >= 100.0:
			change_state(State.FINISHED)
			
			# Notify the Global TaskManager if it exists
			if Engine.has_singleton("TaskManager"):
				# Replace 'printer' with the exact Task ID you used in your catalog
				get_node("/root/TaskManager").complete_task_by_type("printer")

func change_state(new_state):
	current_state = new_state
	state_changed.emit(new_state)

# Commands called by the UI
func start_load_sequence():
	change_state(State.WAITING_FOR_PAPER)

func insert_paper():
	progress = 0.0
	change_state(State.PRINTING)

func fix_jam():
	# Resumes printing after fixing the jam
	change_state(State.PRINTING)

func collect_docs():
	# Reset the printer to IDLE
	change_state(State.IDLE)
	progress = 0.0


func reset_for_new_game() -> void:
	progress = 0.0
	change_state(State.IDLE)
	progress_updated.emit(progress)
