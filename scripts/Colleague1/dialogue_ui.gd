extends CanvasLayer

signal choice_accepted
signal choice_rejected
signal choice_made(picked_a: bool)

const INNER_WIDTH := 300.0
const DEFAULT_PANEL_HEIGHT := 104.0
const MAX_PANEL_HEIGHT := 190.0
const DEFAULT_HALF_WIDTH := 147.5
const WIDE_HALF_WIDTH := 165.0
const BOTTOM_MARGIN := 10.0
const NAME_TAG_ABOVE := 8.0
const NAME_TAG_HEIGHT := 21.0
const VBOX_SEPARATION := 10.0
const PANEL_PADDING_V := 30.0
const BUTTON_PADDING := 20.0
const BUTTON_GAP := 8.0

@onready var _dialogue_root: Control = $Control/DialogueRoot
@onready var _margin_container: MarginContainer = $Control/DialogueRoot/MarginContainer
@onready var _vbox: VBoxContainer = $Control/DialogueRoot/MarginContainer/PanelContainer/VBoxContainer
@onready var name_label: Label = $Control/DialogueRoot/NameTag
@onready var content_label: RichTextLabel = $Control/DialogueRoot/MarginContainer/PanelContainer/VBoxContainer/ContentText
@onready var _hbox_row: HBoxContainer = $Control/DialogueRoot/MarginContainer/PanelContainer/VBoxContainer/HBoxRow
@onready var _vbox_column: VBoxContainer = $Control/DialogueRoot/MarginContainer/PanelContainer/VBoxContainer/VBoxColumn
@onready var _accept_btn: Button = $Control/DialogueRoot/MarginContainer/PanelContainer/VBoxContainer/HBoxRow/AcceptBtn
@onready var _reject_btn: Button = $Control/DialogueRoot/MarginContainer/PanelContainer/VBoxContainer/HBoxRow/RejectBtn

var _using_vertical: bool = false
var _dynamic_layout: bool = false


func _ready() -> void:
	if not _accept_btn.pressed.is_connected(_on_accept_btn_pressed):
		_accept_btn.pressed.connect(_on_accept_btn_pressed)
	if not _reject_btn.pressed.is_connected(_on_reject_btn_pressed):
		_reject_btn.pressed.connect(_on_reject_btn_pressed)
	_apply_shrink_vertical(_vbox)
	_apply_shrink_vertical(content_label)
	_apply_shrink_vertical(_hbox_row)
	_apply_shrink_vertical(_vbox_column)
	_apply_shrink_vertical(_accept_btn)
	_apply_shrink_vertical(_reject_btn)
	call_deferred("_sync_name_tag_when_static")


func _sync_name_tag_when_static() -> void:
	await get_tree().process_frame
	if _dynamic_layout:
		return
	_sync_name_tag_to_panel_top()


func setup_dialogue(speaker_name: String, dialogue_text: String) -> void:
	name_label.text = speaker_name
	content_label.text = dialogue_text
	_hbox_row.show()
	_vbox_column.hide()
	if _dynamic_layout:
		call_deferred("_sync_dialogue_layout")


func set_choice_labels(a_text: String, b_text: String) -> void:
	_accept_btn.text = a_text
	_reject_btn.text = b_text
	if _dynamic_layout:
		_layout_choice_buttons()
		call_deferred("_sync_dialogue_layout")


func show_step(speaker_name: String, dialogue_text: String, a_text: String, b_text: String) -> void:
	_using_vertical = false
	_enable_lunch_layout()
	setup_dialogue(speaker_name, dialogue_text)
	set_choice_labels(a_text, b_text)


func _enable_lunch_layout() -> void:
	if _dynamic_layout:
		return
	_dynamic_layout = true
	_vbox.custom_minimum_size.x = INNER_WIDTH
	content_label.custom_minimum_size.x = INNER_WIDTH
	content_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL


func _apply_shrink_vertical(control: Control) -> void:
	control.size_flags_vertical = Control.SIZE_SHRINK_BEGIN


func _layout_choice_buttons() -> void:
	for btn in [_accept_btn, _reject_btn]:
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_apply_shrink_vertical(btn)

	var font: Font = _accept_btn.get_theme_font(&"font")
	var font_size: int = _accept_btn.get_theme_font_size(&"font_size")
	var a_width := font.get_string_size(_accept_btn.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x + BUTTON_PADDING
	var b_width := font.get_string_size(_reject_btn.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x + BUTTON_PADDING
	var use_vertical := a_width + b_width + BUTTON_GAP > INNER_WIDTH

	if use_vertical != _using_vertical:
		_using_vertical = use_vertical
		if use_vertical:
			_move_buttons_to(_vbox_column)
			_hbox_row.visible = false
			_vbox_column.visible = true
		else:
			_move_buttons_to(_hbox_row)
			_vbox_column.visible = false
			_hbox_row.visible = true

	if use_vertical:
		_vbox_column.add_theme_constant_override("separation", 6)
		for btn in [_accept_btn, _reject_btn]:
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.custom_minimum_size.x = INNER_WIDTH
	else:
		_hbox_row.add_theme_constant_override("separation", 8)
		for btn in [_accept_btn, _reject_btn]:
			btn.autowrap_mode = TextServer.AUTOWRAP_OFF
			btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			btn.custom_minimum_size = Vector2.ZERO

	_apply_shrink_vertical(_hbox_row)
	_apply_shrink_vertical(_vbox_column)


func _move_buttons_to(container: Node) -> void:
	if _accept_btn.get_parent() == container and _reject_btn.get_parent() == container:
		return
	if _accept_btn.get_parent():
		_accept_btn.get_parent().remove_child(_accept_btn)
	if _reject_btn.get_parent():
		_reject_btn.get_parent().remove_child(_reject_btn)
	container.add_child(_accept_btn)
	container.add_child(_reject_btn)


func _measure_panel_height() -> float:
	var content_h := float(content_label.get_content_height())
	var buttons_h := 0.0
	if _vbox_column.visible:
		buttons_h = _vbox_column.get_minimum_size().y
	elif _hbox_row.visible:
		buttons_h = _hbox_row.get_minimum_size().y
	return PANEL_PADDING_V + content_h + VBOX_SEPARATION + buttons_h


func _apply_box_size(panel_h: float, half_width: float) -> void:
	panel_h = clampf(panel_h, DEFAULT_PANEL_HEIGHT, MAX_PANEL_HEIGHT)
	var root_h := panel_h + BOTTOM_MARGIN
	_dialogue_root.offset_left = -half_width
	_dialogue_root.offset_right = half_width - 3.0
	_dialogue_root.offset_top = -root_h
	_dialogue_root.offset_bottom = 0.0
	_margin_container.offset_top = -panel_h
	_margin_container.offset_bottom = 0.0


func _sync_name_tag_to_panel_top() -> void:
	var panel_top := _margin_container.position.y
	name_label.offset_top = panel_top - NAME_TAG_ABOVE
	name_label.offset_bottom = name_label.offset_top + NAME_TAG_HEIGHT


func _sync_dialogue_layout() -> void:
	if not _dynamic_layout:
		return
	_apply_box_size(DEFAULT_PANEL_HEIGHT, WIDE_HALF_WIDTH)
	await get_tree().process_frame
	await get_tree().process_frame
	var panel_h := _measure_panel_height()
	_apply_box_size(panel_h, WIDE_HALF_WIDTH)
	await get_tree().process_frame
	_sync_name_tag_to_panel_top()


func _on_accept_btn_pressed() -> void:
	choice_accepted.emit()
	choice_made.emit(true)


func _on_reject_btn_pressed() -> void:
	choice_rejected.emit()
	choice_made.emit(false)


func show_feedback(feedback_text: String) -> void:
	content_label.text = feedback_text
	_hbox_row.hide()
	_vbox_column.hide()
	if _dynamic_layout:
		call_deferred("_sync_dialogue_layout")
	await get_tree().create_timer(2.0, true, false, true).timeout
	queue_free()
