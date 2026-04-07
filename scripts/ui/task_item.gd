extends HBoxContainer

## Single task row (develoment §4). Navigation only; completion via TaskManager.

var _instance: TaskInstance

@onready var _icon_rect: TextureRect = $TextureRect
@onready var _name_label: Label = $NameLabel
@onready var _money_label: Label = $MoneyLabel
@onready var _time_label: Label = $TimeLabel
@onready var _goto_button: Button = $GotoButton


func setup(inst: TaskInstance) -> void:
	_instance = inst
	_name_label.text = inst.task_name
	_money_label.text = str(inst.reward_money)
	if inst.icon != null:
		_icon_rect.texture = inst.icon
	set_process(true)
	_goto_button.pressed.connect(_on_goto_pressed)


func _process(_delta: float) -> void:
	if _instance == null:
		return
	var t: int = int(ceil(maxf(_instance.remaining_time, 0.0)))
	var m: int = t / 60
	var s: int = t % 60
	_time_label.text = "%02d:%02d" % [m, s]


func _on_goto_pressed() -> void:
	if _instance != null:
		TaskManager.request_navigation(_instance.instance_id)
