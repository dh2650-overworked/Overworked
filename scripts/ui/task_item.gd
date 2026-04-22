extends HBoxContainer

## Single task row (develoment §4). Completion display only.

const INK_COLOR := Color(0.0, 0.1, 0.4, 1.0)
const RULE_COLOR := Color(0.6, 0.7, 0.9, 0.5)
const COMPLETED_COLOR := Color(0.35, 0.42, 0.62, 0.62)
const STRIKE_COLOR := Color(0.35, 0.42, 0.62, 0.9)

var _instance: TaskInstance
var _is_completed: bool = false
var _rule_line: Line2D
var _strike_line: Line2D

@onready var _name_label: Label = $NameLabel
@onready var _money_label: Label = $MoneyLabel


func _ready() -> void:
	_ensure_rule_line()
	resized.connect(_on_resized)


func setup(inst: TaskInstance) -> void:
	_instance = inst
	_name_label.text = inst.task_name
	_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name_label.add_theme_color_override("font_color", INK_COLOR)
	_money_label.text = str(inst.reward_money)
	_money_label.add_theme_color_override("font_color", INK_COLOR)
	_update_rule_line()


func mark_as_completed() -> void:
	if _is_completed:
		return
	_is_completed = true

	_name_label.add_theme_color_override("font_color", COMPLETED_COLOR)
	_money_label.add_theme_color_override("font_color", COMPLETED_COLOR)
	_ensure_strike_line()
	_update_strike_line()


func _on_resized() -> void:
	_update_rule_line()
	_update_strike_line()


func _ensure_rule_line() -> void:
	if _rule_line != null:
		return
	_rule_line = Line2D.new()
	_rule_line.name = "RuleLine"
	_rule_line.default_color = RULE_COLOR
	_rule_line.width = 1.0
	_rule_line.antialiased = true
	add_child(_rule_line)
	_update_rule_line()


func _update_rule_line() -> void:
	if _rule_line == null:
		return
	var y := maxf(size.y - 1.0, 0.0)
	_rule_line.points = PackedVector2Array([Vector2(0.0, y), Vector2(size.x, y)])


func _ensure_strike_line() -> void:
	if _strike_line != null:
		return
	_strike_line = Line2D.new()
	_strike_line.name = "CompletedStrikeLine"
	_strike_line.default_color = STRIKE_COLOR
	_strike_line.width = 2.4
	_strike_line.antialiased = true
	add_child(_strike_line)


func _update_strike_line() -> void:
	if _strike_line == null:
		return
	var font: Font = _name_label.get_theme_font("font")
	var font_size: int = _name_label.get_theme_font_size("font_size")
	var text_width: float = 0.0
	if font != null:
		text_width = font.get_string_size(_name_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	else:
		text_width = _name_label.size.x

	var start_x := _name_label.position.x + 2.0
	var end_x := start_x + maxf(text_width - 4.0, 2.0)
	var y := _name_label.position.y + (_name_label.size.y * 0.55)
	_strike_line.points = PackedVector2Array([Vector2(start_x, y), Vector2(end_x, y)])
