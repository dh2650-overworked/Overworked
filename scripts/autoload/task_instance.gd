extends RefCounted
class_name TaskInstance

## Runtime task row (no time limit / expiry).

var instance_id: String = ""
var task_id: String = ""
var task_name: String = ""
var icon: Texture2D
var reward_money: int = 0
var scene_path: String = ""
var is_inherited: bool = false

static func from_task_data(data: TaskData) -> TaskInstance:
	var inst := TaskInstance.new()
	if data == null:
		return inst
	inst.task_id = data.task_id
	inst.task_name = data.task_name
	inst.icon = data.icon
	inst.reward_money = data.reward_money
	inst.scene_path = data.scene_path
	return inst
