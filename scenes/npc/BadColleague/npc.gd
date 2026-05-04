extends Area2D # 或者 CharacterBody2D，取决于你 NPC 的根节点

# --- 1. 对话内容池 ---
var lines = [
	"Deadline is coming, move it!",
	"Why are you just standing there?",
	"The boss is watching...",
	"Did you finish that report?"
]

# --- 2. 节点引用 ---
@onready var dialog_label = $Label # 确保你 NPC 下面有一个叫 Label 的子节点

func _ready():
	# 初始状态隐藏对话框
	dialog_label.visible = false
	
	# 【核心：放这里】连接打印机大脑的信号
	# 这样无论玩家在哪，只要打印机卡纸，NPC 就能“听到”
	PrinterManager.state_changed.connect(_on_printer_changed)
	
	# 连接玩家靠近的信号（需要在编辑器里连，或者代码连）
	self.body_entered.connect(_on_player_entered)
	self.body_exited.connect(_on_player_exited)

# --- 3. 核心逻辑：打印机卡纸时的反应 ---
func _on_printer_changed(new_state):
	# 如果打印机卡纸了 (JAMMED)
	if new_state == PrinterManager.State.JAMMED:
		dialog_label.text = "I HEAR THE PRINTER JAMMING! FIX IT NOW!"
		dialog_label.visible = true
		# 强制让文字变成红色（可选，增加压力感）
		dialog_label.modulate = Color.RED 
	else:
		# 如果修好了，文字恢复颜色并消失
		dialog_label.modulate = Color.WHITE
		dialog_label.visible = false

# --- 4. 基础逻辑：玩家走近时的随机对话 ---
func _on_player_entered(body):
	if body.name == "Player": # 确保你的玩家节点叫 Player
		if PrinterManager.current_state != PrinterManager.State.JAMMED:
			dialog_label.text = lines.pick_random()
			dialog_label.visible = true

func _on_player_exited(body):
	if body.name == "Player":
		dialog_label.visible = false
