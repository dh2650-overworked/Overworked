extends Resource
class_name DayData

## Per-day schedule: assign a DayData .tres on each day's Main scene (inspector).
## timed_tasks: keys are trigger times in seconds since level start (float or string "120.0");
## values are TaskData resources to add at that time.

@export var day_id: String = ""
@export var day_label: String = ""
## TaskData .tres entries (untyped Array avoids parser/global-class ordering issues).
@export var start_tasks: Array = []
@export var timed_tasks: Dictionary = {}
@export_file("*.tscn") var next_day_scene_path: String = ""
## NPC ids present today (e.g. "peter", "lucy", "john"). Others stay hidden.
@export var active_npcs: Array = []
