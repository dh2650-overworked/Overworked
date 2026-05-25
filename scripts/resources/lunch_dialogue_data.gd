extends Resource
class_name LunchDialogueData

@export var speaker_name: String = ""
@export_multiline var opening_text: String = ""
@export_multiline var choice_a_text: String = ""
@export_multiline var choice_b_text: String = ""
@export_multiline var choice_a_feedback: String = ""
@export_multiline var choice_b_feedback: String = ""
@export var choice_a_has_followup: bool = false
@export_multiline var followup_text: String = ""
@export_multiline var followup_a_text: String = ""
@export_multiline var followup_b_text: String = ""
@export_multiline var followup_a_feedback: String = ""
@export_multiline var followup_b_feedback: String = ""
