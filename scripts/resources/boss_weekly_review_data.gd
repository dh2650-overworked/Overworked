extends Resource
class_name BossWeeklyReviewData

## Boss weekly review lines. opening_2 uses %d for weekly points total.
## Edit all text in the Inspector on boss_weekly_review.tres.

@export var speaker_name: String = "Boss"
@export var chat_threshold: int = 1

@export_multiline var opening_1: String = ""
@export_multiline var opening_2: String = ""

@export_multiline var unfinished_first_time: String = ""
@export_multiline var unfinished_second_time: String = ""

@export_multiline var all_finished_intro: String = ""
@export_multiline var with_delay: String = ""
@export_multiline var without_delay: String = ""

@export_multiline var chat_enough: String = ""
@export_multiline var chat_too_few: String = ""

@export_multiline var ending_week0: String = ""
@export_multiline var ending_week1: String = ""
