extends CharacterBody2D

# --- 1. Teammate's Exported Variables ---
@export var dialogue_scene: PackedScene 
@export var report_task: Resource       
@export var run_speed: float = 180.0    
var player_in_range = false

# --- 2. Fire & Panic Logic ---
var is_fleeing: bool = false
var is_returning: bool = false
var original_pos: Vector2       
var exit_target: Vector2 = Vector2.ZERO


var bounce_tween: Tween
var rotate_tween: Tween

# --- 3. Overhead Dialogue Settings ---
var random_lines = [
	"Deadline is coming, move it!",
	"Why are you just standing there?",
	"The boss is watching...",
	"Did you finish that report?"
]
var is_dialogue_active: bool = false # 防止重复弹窗

# --- 2. Overhead Dialogue Settings ---

@onready var speech_label = $Label 
@onready var sprite = $Boss 

func _ready() -> void:
	original_pos = global_position
	print("!!! NPC SCRIPT IS ALIVE !!!")

	var interaction_area = get_node_or_null("InteractionArea")
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)

	PrinterManager.state_changed.connect(_on_printer_changed)

	var fm = get_node_or_null("/root/FireManager")
	if fm:
		fm.fire_started.connect(_on_fire_started)
		fm.fire_ended.connect(_on_fire_ended)
		print("NPC: FIRE SIGNALS CONNECTED!")

func _on_fire_started():
	print("NPC: Received fire signal! Running now!")
	start_fleeing(Vector2(500, 500)) 

func _on_fire_ended():
	self.visible = true  
	is_fleeing = false
	is_returning = true 
	print("NPC: Fire drill over, bouncing back home.")

func _physics_process(_delta: float) -> void:
	if is_fleeing:
		_move_to(exit_target)
		if global_position.distance_to(exit_target) < 50.0:
			is_fleeing = false     
			velocity = Vector2.ZERO
			self.visible = false 
			print("NPC: Hidden at exit.")
			
	elif is_returning:
		self.visible = true 
		_move_to(original_pos)
		if global_position.distance_to(original_pos) < 50.0:
			_stop_moving() # 
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func _move_to(target: Vector2):
	var direction = global_position.direction_to(target)
	velocity = direction * run_speed
	sprite.flip_h = (direction.x < 0)

func _stop_moving():
	is_fleeing = false
	is_returning = false
	velocity = Vector2.ZERO
	
	if bounce_tween: bounce_tween.kill()
	if rotate_tween: rotate_tween.kill()
	
	# 恢复原状
	sprite.rotation = 0
	sprite.scale = Vector2.ONE
	
	if speech_label: 
		speech_label.visible = false
	print("NPC: Movement fully stopped and animations cleared.")

func start_fleeing(target_pos: Vector2):
	if is_fleeing: return 
	is_fleeing = true
	exit_target = target_pos
	
	if speech_label:
		speech_label.text = "FIRE! RUN!!!"
		speech_label.modulate = Color.ORANGE_RED
		speech_label.visible = true
	
	animate_panic_bounce()

func animate_panic_bounce():
	if bounce_tween: bounce_tween.kill()
	if rotate_tween: rotate_tween.kill()

	bounce_tween = create_tween().set_loops()
	bounce_tween.tween_property(sprite, "scale", Vector2(1.2, 0.8), 0.1)
	bounce_tween.tween_property(sprite, "scale", Vector2(0.8, 1.2), 0.1)
	
	rotate_tween = create_tween().set_loops()
	rotate_tween.tween_property(sprite, "rotation_degrees", 15.0, 0.08)
	rotate_tween.tween_property(sprite, "rotation_degrees", -15.0, 0.08)


func _on_body_entered(body: Node2D) -> void:
	if is_fleeing or is_returning or not self.visible: return
	if body.is_in_group("player"):
		player_in_range = true
		speech_label.text = random_lines.pick_random()
		speech_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if speech_label: speech_label.visible = false

# --- 5. 打印机卡纸逻辑 (强制对话) ---

func _on_printer_changed(new_state):
	if is_fleeing or is_returning: return 
	
	if new_state == PrinterManager.State.JAMMED:
		# 变红脸显示愤怒
		sprite.modulate = Color(1.5, 0.5, 0.5) 
		# 只有不在说话时才弹窗
		if not is_dialogue_active:
			trigger_boss_confrontation()
	else:
		sprite.modulate = Color.WHITE

func trigger_boss_confrontation():
	if is_dialogue_active: return
	is_dialogue_active = true
	
	var ui = dialogue_scene.instantiate()
	ui.name = "DialogueUI"
	get_tree().root.add_child(ui)
	
	# 1. 修改文字 (Boss语气)
	var label_node = ui.find_child("ContentText", true, false)
	if label_node: label_node.text = "I HEAR THE MACHINE JAMMING! FIX IT NOW!"

	# 2. 【核心连接】：必须在这里手动把 UI 的信号和 Boss 的功能连起来
	ui.choice_accepted.connect(func(): 
		print("BOSS: Player accepted!")
		ui.show_feedback("Now move it!") # 调用 UI 里的反馈函数，2秒后自动消失
		is_dialogue_active = false
	)
	
	ui.choice_rejected.connect(func(): 
		print("BOSS: Player rejected!")
		ui.show_feedback("I'M DOCKING YOUR PAY!") 
		TaskManager.total_money -= 50
		is_dialogue_active = false
	)




func _input(event):
	if is_fleeing or is_returning: return
	if player_in_range and event.is_action_pressed("interact"):
		if not get_tree().root.has_node("DialogueUI"):
			start_dialogue()

func start_dialogue():
	var ui = dialogue_scene.instantiate()
	ui.name = "DialogueUI"
	get_tree().root.add_child(ui)
	
