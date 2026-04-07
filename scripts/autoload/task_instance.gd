extends RefCounted
class_name TaskInstance

## Runtime task row; remaining_time is driven by TaskManager.

var instance_id: String = ""
var task_id: String = ""
var task_name: String = ""
var icon: Texture2D
var reward_money: int = 0
var time_limit: float = 0.0
var remaining_time: float = 0.0

static func from_task_data(data: TaskData) -> TaskInstance:
	var inst := TaskInstance.new()
	inst.task_id = data.task_id
	inst.task_name = data.task_name
	inst.icon = data.icon
	inst.reward_money = data.reward_money
	inst.time_limit = data.time_limit
	inst.remaining_time = data.time_limit
	return inst
