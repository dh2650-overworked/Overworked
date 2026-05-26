extends TextureButton

var _music_pos: float = 0.0
var _leave_was_overtime: bool = false
var _had_music_playing: bool = false


func _main() -> Node:
	return get_tree().current_scene


func _on_mouse_entered() -> void:
	$Label.show()


func _on_mouse_exited() -> void:
	$Label.hide()


func _on_pressed() -> void:
	_leave_was_overtime = TaskManager.is_overtime
	_had_music_playing = false
	if _leave_was_overtime:
		var ot := _main().get_node_or_null("office/OvertimeMusic") as AudioStreamPlayer
		if ot and ot.playing:
			_music_pos = ot.get_playback_position()
			_had_music_playing = true
	else:
		var day := _main().get_node_or_null("office/AudioStreamPlayer") as AudioStreamPlayer
		if day and day.playing:
			_music_pos = day.get_playback_position()
			_had_music_playing = true
	$"../ConfirmOverlay".show()
	get_tree().paused = true


func _on_yes_button_pressed() -> void:
	$"../ConfirmOverlay".hide()
	var main := _main()
	if main.has_method("stop_level_music"):
		main.stop_level_music()
	TaskManager.summary_requested.emit()


func _on_no_button_pressed() -> void:
	$"../ConfirmOverlay".hide()
	get_tree().paused = false
	if not _had_music_playing:
		return
	if _leave_was_overtime:
		var ot := _main().get_node_or_null("office/OvertimeMusic") as AudioStreamPlayer
		if ot:
			ot.play(_music_pos)
	else:
		var day := _main().get_node_or_null("office/AudioStreamPlayer") as AudioStreamPlayer
		if day:
			day.play(_music_pos)
