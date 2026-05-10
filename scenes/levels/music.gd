extends Node2D

# References to your nodes
@onready var env_color = $CanvasModulate
@onready var alarm_sound = $AlarmSound

func _ready():
	# Connect to the manager
	FireManager.fire_started.connect(_on_fire_started)
	FireManager.fire_ended.connect(_on_fire_ended)
#	TODO? Should the sims music be in the music manager or an audio stream player?
	#MusicManager.start_work()
# --- SIMPLE TRIGGER: Press F to start fire, G to stop ---
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F:
			print("DEBUG: F pressed - Starting Fire")
			FireManager.trigger_fire_drill()
		if event.keycode == KEY_G:
			print("DEBUG: G pressed - Stopping Fire")
			FireManager.stop_fire()

func _on_fire_started():
	# Turn office red
	var tween = create_tween()
	tween.tween_property(env_color, "color", Color(1, 0.4, 0.4), 1.0)
	alarm_sound.play()

func _on_fire_ended():
	# Reset to normal
	var tween = create_tween()
	tween.tween_property(env_color, "color", Color.WHITE, 1.0)
	alarm_sound.stop()
