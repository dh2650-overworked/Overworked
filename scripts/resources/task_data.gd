extends Resource
class_name TaskData

## Task template for editor-friendly .tres assets (PRD §3 / develoment §2).

enum DispatchMode {
	## Only spawned when gameplay calls TaskManager.add_task(this) (NPCs, cutscenes, etc.).
	MANUAL_ONLY = 0,
	## May be rolled by TaskManager automatic dispatch; you can still add_task manually.
	AUTO_POOL = 1,
}

@export var task_id: String = ""
@export var task_name: String = ""
@export var icon: Texture2D
@export var reward_money: int = 0
@export var time_limit: float = 60.0
@export var scene_path: String = ""

@export var dispatch_mode: DispatchMode = DispatchMode.AUTO_POOL
## Relative weight when this task is in the AUTO_POOL and auto-dispatch rolls (higher = more likely).
@export_range(0.001, 100.0, 0.001, "or_greater") var auto_dispatch_weight: float = 1.0

@export var is_starter_task: bool = false
## Seconds after level start before this AUTO_POOL task is merged into the auto-dispatch pool (ignored for MANUAL_ONLY).
@export var unlock_time: float = 0.0
