extends Resource
class_name TaskData

## Task template for editor-friendly .tres assets.

@export var task_id: String = ""
@export var task_name: String = ""
@export var icon: Texture2D
@export var reward_money: int = 0
@export var scene_path: String = ""
@export var max_count: int = 1
