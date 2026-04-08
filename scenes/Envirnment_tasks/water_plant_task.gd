extends CanvasLayer

# 信号：任务结束，通知主程序
signal task_finished(success)

@export_group("Task Settings")
@export var grow_speed: float = 35.0   # 浇水增长的速度，数值越大长得越快
@export var target_row: int = 2        # 目标行索引（2代表第3行）
@export var h_frames: int = 5          # 你的图片一行有几个小图

var progress: float = 0.0              # 当前进度 (0-100)
var is_completed: bool = false         # 任务是否已完成

@onready var plant = $Plant
@onready var progress_bar = $ProgressBar

func _ready():
	# 初始化：将进度条设为0，并将植物设为该行第一个要用的帧
	progress = 0.0
	progress_bar.value = 0.0
	update_plant_visuals()

func _process(delta):
	if is_completed:
		return

	# 检测玩家是否按住鼠标左键
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		water_logic(delta)

func water_logic(delta):
	if progress < 100.0:
		progress += grow_speed * delta
		progress_bar.value = progress
		
		# 实时更新植物的样子
		update_plant_visuals()
		
		# 检查是否达标
		if progress >= 100.0:
			complete_task()

func update_plant_visuals():
	# 逻辑：跳过该行第一个（通常是种子），使用剩下的4个
	# 计算起始帧：(行索引 * 每行帧数) + 1
	var start_frame = (target_row * h_frames) + 1
	
	# 将 0-100 映射到 0, 1, 2, 3 四个偏移量上
	# 25.1 是为了防止 progress 为 100 时索引越界变成 4
	var offset = int(progress / 25.1)
	
	# 设置植物的 Frame
	plant.frame = start_frame + offset


# 如果你添加了退出按钮，可以将它的 pressed 信号连接到这里
func _on_exit_button_pressed():
	emit_signal("task_finished", false)
	queue_free()
@onready var success_overlay = $SuccessOverlay # 新增：引用完成面板
func complete_task():
	is_completed = true
	
	# 1. 显示完成面板
	success_overlay.visible = true
	
	# 2. 可以加个小动画（可选）：让面板从小变大
	success_overlay.scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(success_overlay, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK)

	print("任务完成！")
	
	# 3. 停顿 2 秒，让玩家看清楚“任务完成”
	await get_tree().create_timer(2.0).timeout
	
	# 4. 退出
	emit_signal("task_finished", true)
	queue_free()
