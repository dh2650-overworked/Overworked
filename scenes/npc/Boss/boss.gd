extends CharacterBody2D

# --- 1. Settings ---
@export var normal_speed: float = 70.0
@export var angry_speed: float = 160.0
@export var flee_speed: float = 200.0

# --- 2. Path Thresholds (调整这里的数值来对齐你的地图) ---
@export var DOOR_Y_LIMIT: float = 330.0 # 办公室门口的 Y 坐标
@export var ROOM_X_ENTRANCE: float = 1080.0 # 办公室门口的 X 坐标

var original_pos: Vector2
var is_fleeing: bool = false
var is_angry: bool = false
var exit_pos: Vector2 = Vector2(2500, 500) # Office main exit

@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer
@onready var label = $Label

func _ready():
	# Record where the boss sits at the start
	original_pos = global_position
	label.visible = false
	
	# Listen to global signals
	PrinterManager.state_changed.connect(_on_printer_problem)
	if Engine.has_singleton("FireManager"):
		FireManager.fire_started.connect(_on_fire_started)

func _physics_process(_delta):
	# Priority 1: Fire Drill (Squash and Stretch Panic)
	if is_fleeing:
		var dir = global_position.direction_to(exit_pos)
		velocity = dir * flee_speed
		sprite.flip_h = (dir.x < 0)
		move_and_slide()
		if global_position.distance_to(exit_pos) < 30.0:
			queue_free()
		return

	# Priority 2: Printer Jam or Returning to Desk
	handle_segmented_movement()
	move_and_slide()

func handle_segmented_movement():
	var target_vel = Vector2.ZERO
	
	if is_angry:
		# --- 去查岗的逻辑保持不变 ---
		var printer = get_tree().root.find_child("Printer", true, false)
		if printer:
			var target_spot = printer.global_position + Vector2(0, 40)
			if global_position.y < DOOR_Y_LIMIT:
				target_vel = Vector2(0, 1) * angry_speed
			elif abs(global_position.x - target_spot.x) > 10.0:
				var x_dir = 1 if target_spot.x > global_position.x else -1
				target_vel = Vector2(x_dir, 0) * angry_speed
			else:
				# 到了打印机
				target_vel = Vector2.ZERO
				anim.play("idle")
				label.text = "FIX IT!"
	else:
		# --- 修复回位的逻辑：先对齐 X，再向上走 ---
		# 如果老板离座位的 X 坐标很远，先横向移动
		if abs(global_position.x - original_pos.x) > 10.0:
			var x_dir = -1 if global_position.x > original_pos.x else 1
			target_vel = Vector2(x_dir, 0) * normal_speed
		# X 对齐了，再向上（Y 减少）回位
		elif global_position.y > original_pos.y + 5.0:
			target_vel = Vector2(0, -1) * normal_speed
		else:
			# 回到座位
			target_vel = Vector2.ZERO
			anim.play("idle")
			label.visible = false

	velocity = target_vel
	if velocity != Vector2.ZERO:
		anim.play("walk")
		sprite.flip_h = (velocity.x < 0)

	

# --- Event Handlers ---

func _on_printer_problem(new_state):
	if is_fleeing: return
	if new_state == PrinterManager.State.JAMMED:
		is_angry = true
		sprite.modulate = Color(1.5, 0.5, 0.5) 
	else:
		is_angry = false
		sprite.modulate = Color.WHITE

func _on_fire_started():
	is_fleeing = true
	is_angry = false
	label.text = "RUN FOR YOUR LIVES!!!"
	label.visible = true
	animate_frantic_hop()

func animate_frantic_hop():
	var tween = create_tween().set_loops()
	tween.tween_property(sprite, "scale", Vector2(1.3, 0.7), 0.1)
	tween.tween_property(sprite, "scale", Vector2(0.7, 1.3), 0.1)
	var rot_tween = create_tween().set_loops()
	rot_tween.tween_property(sprite, "rotation_degrees", 20, 0.08)
	rot_tween.tween_property(sprite, "rotation_degrees", -20, 0.08)
