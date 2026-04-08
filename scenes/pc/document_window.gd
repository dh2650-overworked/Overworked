extends Window


var active_text = null
var current_letter_index: int = -1


func find_new_active_text(typed_character: String):
	var prompt = $TextReport.get_prompt()
	if prompt.substr(0,1) == typed_character:
		active_text = $TextReport
		current_letter_index = 1
		active_text.set_next_character(current_letter_index)
		

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		var typed_event = event as InputEventKey
		var key_typed = PackedByteArray([typed_event.unicode]).get_string_from_utf8()
		
		
		if active_text == null:
			find_new_active_text(key_typed)
		else: 
			var prompt = active_text.get_prompt()
			var next_character = prompt.substr(current_letter_index,1)
			if key_typed == next_character.to_lower():
				print("you right")
				current_letter_index += 1
				active_text.set_next_character(current_letter_index)
				if current_letter_index == prompt.length():
					current_letter_index =-1
					print("you have won")
			else: 
				print("incorrectly typed %s instead of %s" % [key_typed, next_character])
