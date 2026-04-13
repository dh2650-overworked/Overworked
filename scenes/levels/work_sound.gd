extends AudioStreamPlayer2D

# This script handles the work sound of the printer.
# It only plays during the PRINTING state.

func _process(_delta: float) -> void:
	# 1. Access the current state of the printer
	var state = PrinterManager.current_state
	
	# 2. Logic: ONLY play if state is PRINTING
	if state == PrinterManager.State.PRINTING:
		if not playing:
			play()
			
	# 3. Logic: STOP if state is JAMMED, IDLE, or FINISHED
	elif state == PrinterManager.State.JAMMED or state == PrinterManager.State.IDLE:
		if playing:
			stop()
	
	# Optional: Fallback to stop for any other states
	else:
		if playing:
			stop()
