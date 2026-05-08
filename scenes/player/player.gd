extends CharacterBody2D

# --- 1. 定义变量，方便在右侧检查器调整 ---
@export var speed: float = 250.0        # 移动速度
@export var acceleration: float = 0.2    # 加速度 (数值越小越有“滑冰”感)
@export var friction: float = 0.2        # 摩擦力 (停下的快慢)

# --- 2. 获取子节点引用 (名字必须和你场景里的节点名一模一样) ---
@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer

func _physics_process(_delta: float) -> void:
	# 3. 获取输入方向 (WASD 或 方向键)
	# 确保你在“项目设置 -> 输入映射”里已经配好了这四个动作
	var input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	# 4. 处理移动逻辑
	if input_direction != Vector2.ZERO:
		# --- 正在走动 ---
		# 使用 lerp 让起步更平滑
		velocity = velocity.lerp(input_direction * speed, acceleration)
		
		# 播放走路动画
		anim_player.play("walk")
		
		# 处理左右翻转 (根据 X 轴正负判定)
		if input_direction.x < 0:
			sprite.flip_h = false   # 向左走，翻转图片
		elif input_direction.x > 0:
			sprite.flip_h = true  # 向右走，恢复原样
			
	else:
		# --- 停在原地 ---
		# 使用 lerp 让停下更有“惯性”
		velocity = velocity.lerp(Vector2.ZERO, friction)
		
		# 播放待机动画
		anim_player.play("idle")

	# 5. 执行物理移动
	move_and_slide()
