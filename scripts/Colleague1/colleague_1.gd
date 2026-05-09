extends CharacterBody2D

# --- 1. Teammate's Exported Variables ---
@export var dialogue_scene: PackedScene 
@export var report_task: Resource       
@export var run_speed: float = 180.0    # Speed when fleeing the fire
var player_in_range = false

# --- 2. Fire & Panic Logic ---
var is_fleeing: bool = false
var is_returning: bool = false  # 新增：标记是否正在走回原位
var original_pos: Vector2       # 新增：记录初始位置
var exit_target: Vector2 = Vector2.ZERO

# --- 3. Your Overhead Dialogue Settings ---
var random_lines = [
	"Deadline is coming, move it!",
	"Why are you just standing there?",
	"The boss is watching...",
	"Did you finish that report?"
]

@onready var speech_label = $Label 
@onready var sprite = $Kevin # Reference to the static image
func _ready() -> void:
	original_pos = global_position
	print("!!! NPC SCRIPT IS ALIVE !!!")

	# 1. 安全连接交互区域 (即使找不到也不报错)
	var interaction_area = get_node_or_null("InteractionArea")
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)
		print("NPC: InteractionArea linked.")
	else:
		print("NPC: InteractionArea not found, skipping...")

	# 2. 安全连接火灾信号
	# 使用 get_node 绝对路径确保万无一失
	var fm = get_node_or_null("/root/FireManager")
	if fm:
		fm.fire_started.connect(_on_fire_started)
		fm.fire_ended.connect(_on_fire_ended)
		print("NPC: FIRE SIGNALS CONNECTED!") # 👈 运行后看控制台有没有这行
	else:
		push_error("NPC: FireManager singleton not found! Check Autoload settings.")
#func _ready() -> void:
	#original_pos = global_position
	#print("!!! NPC SCRIPT IS ALIVE !!!")
	#
	#$InteractionArea.body_entered.connect(_on_body_entered)
	#$InteractionArea.body_exited.connect(_on_body_exited)
	#
	## Listen to PrinterManager
	#PrinterManager.state_changed.connect(_on_printer_changed)
	#
	#if Engine.has_singleton("FireManager"):
		#print("DEBUG NPC: Found FireManager! Connecting signals...")
		#FireManager.fire_started.connect(_on_fire_started)
		#FireManager.fire_ended.connect(_on_fire_ended)
	#
	## 删掉你之前的那个 3秒 timer 测试代码，改用信号驱动
	#if speech_label: speech_label.visible = false
#
	## --- NEW: Listen for FIRE (Assuming you have a FireManager or similar) ---
	## For testing, you can call start_fleeing(Vector2(2000, 300)) manually
	## FireManager.fire_started.connect(func(): start_fleeing(Vector2(2000, 300)))
	#
	#
	#if speech_label:
		#speech_label.visible = false
		#
func _on_fire_started():
	print("NPC: Received fire signal! Running now!")
	start_fleeing(Vector2(500, 500)) # 触发你写的那些 Q弹 动画和移动逻辑

func _on_fire_ended():
	print("NPC: Fire is over. Going back.")
	is_fleeing = false
	is_returning = true # 触发返回逻辑
# --- NEW: Movement logic during fire ---
func _physics_process(_delta):
	if is_fleeing:
		var direction = global_position.direction_to(exit_target)
		velocity = direction * run_speed
		
		# Flip sprite to look where they are running
		sprite.flip_h = (direction.x < 0)
		
		move_and_slide()
		
		# If they reach the exit (close to target), remove them from the world
		if global_position.distance_to(exit_target) < 20.0:
			queue_free()
func _move_to(target: Vector2):
	var direction = global_position.direction_to(target)
	velocity = direction * run_speed
	sprite.flip_h = (direction.x < 0)
	# 只要在动，就保持 Q弹 动画（如果你之前开启了循环动画）

func _stop_moving():
	is_fleeing = false
	is_returning = false
	velocity = Vector2.ZERO
	# 恢复原状
	sprite.rotation = 0
	sprite.scale = Vector2.ONE
	if speech_label: speech_label.visible = false
# --- NEW: Trigger the Panic ---
func start_fleeing(target_pos: Vector2):
	if is_fleeing: return # Already running
	
	is_fleeing = true
	exit_target = target_pos
	
	# Stop all talking
	if speech_label:
		speech_label.text = "FIRE! RUN FOR YOUR LIVES!!!"
		speech_label.modulate = Color.ORANGE_RED
		speech_label.visible = true
	
	# Start the squash-and-stretch bounce animation for static sprite
	animate_panic_bounce()

# --- NEW: Visual effect for static sprites ---
func animate_panic_bounce():
	var tween = create_tween().set_loops()
	# Squash and stretch (Bouncing up and down)
	tween.tween_property(sprite, "scale", Vector2(1.2, 0.8), 0.1) # Flatten
	tween.tween_property(sprite, "scale", Vector2(0.8, 1.2), 0.1) # Stretch
	
	# Add a frantic rotation wobble
	var rot_tween = create_tween().set_loops()
	rot_tween.tween_property(sprite, "rotation_degrees", 15.0, 0.08)
	rot_tween.tween_property(sprite, "rotation_degrees", -15.0, 0.08)


# --- Your Logic: Printer Jam ---
func _on_printer_changed(new_state):
	if is_fleeing: return # Don't care about printer if on fire
	if speech_label:
		if new_state == PrinterManager.State.JAMMED:
			speech_label.text = "I HEAR THE PRINTER JAMMING! FIX IT NOW!"
			speech_label.modulate = Color.RED
			speech_label.visible = true
		else:
			speech_label.modulate = Color.WHITE
			speech_label.visible = false

func _on_body_entered(body: Node2D) -> void:
	if is_fleeing: return # Can't talk while running
	if body.is_in_group("player"):
		player_in_range = true
		if speech_label and PrinterManager.current_state != PrinterManager.State.JAMMED:
			speech_label.text = random_lines.pick_random()
			speech_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if speech_label: speech_label.visible = false

# --- Interaction Logic (Press E) ---
func _input(event: InputEvent) -> void:
	if is_fleeing: return # Interaction disabled during fire
	if player_in_range and event.is_action_pressed("interact"):
		if not get_tree().root.has_node("DialogueUI"):
			start_dialogue()

func start_dialogue():
	var ui = dialogue_scene.instantiate()
	ui.name = "DialogueUI"
	get_tree().root.add_child(ui)
	ui.choice_accepted.connect(func(): _on_task_accepted(ui))
	ui.choice_rejected.connect(func(): _on_task_rejected(ui))
	if speech_label: speech_label.visible = false

func _on_task_accepted(ui):
	if report_task is TaskData:
		TaskManager.add_task(report_task as TaskData, true)
	ui.show_feedback("Thank you! See you later!")
	await ui.tree_exited
	queue_free()

func _on_task_rejected(ui):
	ui.show_feedback("Oh, I see...")
