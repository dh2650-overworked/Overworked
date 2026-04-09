extends Node2D

@export var green = Color("#000000")
@export var red = Color("ad2a25ff")
@export var blue = Color("1d75d9ff")

@onready var document_window: Window = $".."
@onready var prompt: RichTextLabel = $TypeText
@onready var prompt_text = prompt.text

func get_prompt() -> String:
	return prompt_text


func set_next_character(next_character_index: int):
	var green_text = get_bbcode_color_tag(green) + prompt_text.substr(0, next_character_index) + get_bbcode_end_color_tag()
	var blue_text = get_bbcode_color_tag(blue) + prompt_text.substr(next_character_index, 1) + get_bbcode_end_color_tag()
	var red_text = ""

	if next_character_index != prompt_text.length():
		red_text = get_bbcode_color_tag(red) + prompt_text.substr(next_character_index + 1, prompt_text.length() - next_character_index + 1) + get_bbcode_end_color_tag()

	prompt.parse_bbcode(set_center_tags(green_text + blue_text + red_text))


func set_center_tags(string_to_center: String):
	return  string_to_center


func get_bbcode_color_tag(color: Color) -> String:
	return "[color=#" + color.to_html(false) + "]"


func get_bbcode_end_color_tag() -> String:
	return "[/color]"


# Today I have successfully increased shareholder value by replying to a tidal wave of emails, most of which asked me to confirm receipt of things I had already confirmed receiving. I attended a meeting that could have been an email, then attended a pre-meeting for that meeting, followed by a post-meeting recap that introduced three new meetings.
