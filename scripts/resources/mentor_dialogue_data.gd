extends Resource
class_name MentorDialogueData

## Single-speaker, multi-page narration. Each page shows up as a multi-line
## text box in the Inspector. Empty pages are skipped at runtime, so unused
## slots can be left blank. Use get_pages() to read the non-empty pages.

@export var speaker_name: String = "Mentor"

@export_multiline var page_1: String = ""
@export_multiline var page_2: String = ""
@export_multiline var page_3: String = ""
@export_multiline var page_4: String = ""
@export_multiline var page_5: String = ""
@export_multiline var page_6: String = ""
@export_multiline var page_7: String = ""
@export_multiline var page_8: String = ""
@export_multiline var page_9: String = ""
@export_multiline var page_10: String = ""


func get_pages() -> Array[String]:
	var result: Array[String] = []
	for s in [page_1, page_2, page_3, page_4, page_5,
			page_6, page_7, page_8, page_9, page_10]:
		if s.strip_edges() != "":
			result.append(s)
	return result
