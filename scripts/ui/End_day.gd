extends TextureButton



func _on_mouse_entered() -> void:
	$Label.show()


func _on_mouse_exited() -> void:
	$Label.hide()


func _on_pressed() -> void:
	$"../ConfirmOverlay".show() 
	get_tree().paused = true


func _on_no_button_pressed() -> void:
	$"../ConfirmOverlay".hide() 
	get_tree().paused = false
