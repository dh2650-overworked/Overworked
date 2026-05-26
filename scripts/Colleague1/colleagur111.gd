extends CharacterBody2D

# --- 1. Teammate's Exported Variables ---
@export var dialogue_scene: PackedScene 
@export var report_task: Resource       
@export var run_speed: float = 180.0    
var player_in_range = false
var _friday: bool = false
var _gone: bool = false

# --- 2. Fire & Panic Logic ---
var is_fleeing: bool = false
var is_returning: bool = false
var original_pos: Vector2       
var exit_target: Vector2 = Vector2.ZERO
var is_going_to_lunch: bool = false
var lunch_target: Vector2 = Vector2.ZERO

var bounce_tween: Tween
var rotate_tween: Tween

# --- 3. Overhead Dialogue Settings ---
var random_lines = [
	#"Deadline is coming, move it!",
	#"Why are you just standing there?",
	#"The boss is watching...",
	#"Did you finish that report?"
	"Got a minute? I may have something for you.",
	"How's the week going?"
]

@onready var speech_label = $Label 
@onready var sprite = $Kevin 

func _ready() -> void:
	NpcPhysics.apply_body_collision(self)
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
		
	var main_node = get_node_or_null("/root/Main") # 路径取决于你的主场景名字
	if main_node:
		main_node.lunch_started.connect(start_lunch)
		main_node.lunch_ended.connect(end_lunch)

	var scene = get_tree().current_scene
	if scene and scene.get("day_data"):
		_friday = TaskManager.is_friday(str(scene.day_data.day_id))
	if not _friday:
		visible = false
		NpcPhysics.disable_body_collision(self)

func _on_fire_started():
	NpcPhysics.disable_body_collision(self)
	print("NPC: Received fire signal! Running now!")
	start_fleeing(Vector2(500, 500)) 

func _on_fire_ended():
	if _friday and not _gone:
		NpcPhysics.apply_body_collision(self)
	self.visible = true  
	is_fleeing = false
	is_returning = true 
	print("NPC: Fire drill over, bouncing back home.")

func _physics_process(_delta: float) -> void:
	if is_fleeing:
		_move_to(exit_target)
		if global_position.distance_to(exit_target) < 30.0:
			is_fleeing = false     
			velocity = Vector2.ZERO
			self.visible = false 
			print("NPC: Hidden at exit.")
			
	elif is_going_to_lunch: # <--- 新加的午餐移动逻辑
		# print("lunch time")
		_move_to(lunch_target)
		if global_position.distance_to(lunch_target) < 10.0:
			_stop_moving()
			is_going_to_lunch = false # 停止移动状态
			print("NPC: Arrived at lunch table.")
					
	elif is_returning:
		self.visible = true 
		_move_to(original_pos)
		if global_position.distance_to(original_pos) < 10.0:
			_stop_moving() # 
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func start_lunch() -> void:
	visible = false
	NpcPhysics.disable_body_collision(self)
	if speech_label:
		speech_label.visible = false

func end_lunch() -> void:
	if _gone or not _friday:
		return
	visible = true
	NpcPhysics.apply_body_collision(self)

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
	#print("NPC: Movement fully stopped and animations cleared.")

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



func _on_printer_changed(new_state):
	if is_fleeing or is_returning: return 
	if speech_label:
		if new_state == PrinterManager.State.JAMMED:
			speech_label.text = "FIX THE PRINTER!"
			speech_label.modulate = Color.RED
			speech_label.visible = true
		else:
			speech_label.visible = false

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

func _input(event: InputEvent) -> void:
	if is_fleeing or is_returning or not self.visible: return
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
	if report_task:
		TaskManager.add_task(report_task, true)
	ui.show_feedback("That's what I like to hear.")
	await ui.tree_exited
	_gone = true
	visible = false
	NpcPhysics.disable_body_collision(self)

func _on_task_rejected(ui):
	ui.show_feedback("Understood. Just remember, we look for initiative in interns.")
