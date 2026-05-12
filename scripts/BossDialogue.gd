extends CanvasLayer

# 信号：通知 Boss 脚本玩家点了哪个按钮
signal choice_accepted
signal choice_rejected

# 使用 find_child 自动找人，比写长长的路径更安全
@onready var name_label = find_child("NameTag", true, false)
@onready var content_label = find_child("ContentText", true, false)
@onready var button_container = find_child("HBoxContainer", true, false)

func _ready():
	# 1. 强制设定名字为 Boss
	if name_label:
		name_label.text = "THE MANAGER"
	
	# 2. 检查按钮是否已经在编辑器里连好了，没连的话代码强制连上
	var accept_btn = find_child("AcceptBtn", true, false)
	var reject_btn = find_child("RejectBtn", true, false)
	
	if accept_btn and not accept_btn.pressed.is_connected(_on_accept_btn_pressed):
		accept_btn.pressed.connect(_on_accept_btn_pressed)
	if reject_btn and not reject_btn.pressed.is_connected(_on_reject_btn_pressed):
		reject_btn.pressed.connect(_on_reject_btn_pressed)

# 这个函数可以让 Boss 脚本在生成 UI 时传话进来
func setup_boss_dialogue(dialogue_text: String):
	if content_label:
		content_label.text = dialogue_text
	if button_container:
		button_container.show()

func _on_accept_btn_pressed():
	print("BOSS UI: Player accepted task.")
	choice_accepted.emit()
	# 这里不用写 queue_free，等着 Boss 脚本调用下面的 show_feedback

func _on_reject_btn_pressed():
	print("BOSS UI: Player rejected task.")
	choice_rejected.emit()

# 核心功能：Boss 对你选择的反馈
func show_feedback(feedback_text: String):
	if content_label:
		content_label.text = feedback_text
	
	# 隐藏按钮，防止玩家手快点第二次
	if button_container:
		button_container.hide()
	
	# 视觉效果：如果是坏消息，让文字变红（可选）
	if "pay" in feedback_text.to_lower() or "useless" in feedback_text.to_lower():
		content_label.modulate = Color.RED
	
	# 停留 2.5 秒，让玩家感受来自老板的凝视
	await get_tree().create_timer(2.5).timeout
	
	# 彻底销毁这个 UI 窗口
	queue_free()
