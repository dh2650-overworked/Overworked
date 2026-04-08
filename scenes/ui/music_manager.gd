extends Node

# --- Signals ---
# Emits every second with formatted text (e.g., "01:30")
signal time_tick(display_text) 
# Emits when the timer hits the hurry threshold
signal hurry_started           
# Emits when the workday is over
signal day_ended               

# --- Unity-style Inspector Variables ---
@export_group("Level Timer")
@export var total_time: float = 60.0    # Total seconds for the workday
@export var hurry_at: float = 15.0      # Seconds remaining when "Hurry Mode" starts

@export_group("Audio Transition Settings")
@export var transition_duration: float = 2.0  # Duration of the crossfade in seconds
# 1.0 is normal speed, 1.15 is 15% faster
@export_range(1.0, 1.5, 0.01) var hurry_pitch: float = 1.15 

# --- Node References ---
# Ensure these names match your nodes in the scene tree exactly
@onready var normal_player = $NormalPlayer
@onready var hurry_player = $HurryPlayer

# --- Internal Runtime Variables ---
var time_left: float
var is_active: bool = false
var is_hurry: bool = false

func _ready():
	# Keep everything quiet until the level actually starts
	stop_all_music()

# --- Main Entry Point ---
# Call this from your Level script: MusicManager.start_work()
func start_work():
	time_left = total_time
	is_active = true
	is_hurry = false
	
	# Reset and start the normal elevator music
	normal_player.volume_db = 0
	normal_player.pitch_scale = 1.0
	normal_player.play()
	
	# Start hurry music in the background but keep it muted (-80dB)
	# This ensures it's ready to fade in instantly
	hurry_player.volume_db = -80
	hurry_player.pitch_scale = 1.0 
	hurry_player.play()
	
	print("MusicManager: Workday started. Timer: ", total_time, "s")

func _process(delta: float):
	if not is_active: return
	
	if time_left > 0:
		time_left -= delta
		_update_ui_timer()
		
		# Check if we should trigger the hurry phase
		if time_left <= hurry_at and not is_hurry:
			_switch_to_hurry_mode()
	else:
		_on_workday_complete()

# Formats the time into a MM:SS string and sends it to the UI
func _update_ui_timer():
	var minutes = int(time_left) / 60.0
	var seconds = int(time_left) % 60
	var time_string = "%02d:%02d" % [minutes, seconds]
	time_tick.emit(time_string)

# Handles the smooth transition between Normal and Hurry music
func _switch_to_hurry_mode():
	is_hurry = true
	hurry_started.emit()
	print("MusicManager: Transitioning to Hurry Mode. Speed up to: ", hurry_pitch)
	
	# Increase the speed and pitch of the hurry track
	hurry_player.pitch_scale = hurry_pitch
	
	# Use Tweens for a professional crossfade effect
	var crossfade_tween = create_tween().set_parallel(true)
	# Fade OUT normal music
	crossfade_tween.tween_property(normal_player, "volume_db", -80, transition_duration)
	# Fade IN hurry music
	crossfade_tween.tween_property(hurry_player, "volume_db", 0, transition_duration)

func _on_workday_complete():
	stop_all_music()
	day_ended.emit()
	print("MusicManager: Workday finished!")

# Utility function to clean up audio
func stop_all_music():
	is_active = false
	normal_player.stop()
	hurry_player.stop()
