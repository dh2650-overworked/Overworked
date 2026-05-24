extends CharacterBody2D

const _HINT_BUSY := "Busy right now. Let's chat later."
const _HINT_PRESS_E := "Press E to talk."
const _HINT_NOTHING := "Nothing else to talk about for now."
const _HINT_LUNCH := "Heading to lunch..."

@export var npc_id: String = ""
@export var run_speed: float = 180.0
@export var lunch_spot: Vector2 = Vector2(-5, 412)

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _speech_label: Label = $Label
@onready var _interaction_area: Area2D = $InteractionArea

var player_in_range: bool = false
var original_pos: Vector2
var is_fleeing: bool = false
var is_returning: bool = false
var is_going_to_lunch: bool = false
var lunch_target: Vector2 = Vector2.ZERO
var exit_target: Vector2 = Vector2.ZERO

var bounce_tween: Tween
var rotate_tween: Tween
var _base_sprite_scale: Vector2 = Vector2.ONE


func _ready() -> void:
	NpcPhysics.apply_body_collision(self)
	add_to_group("lunch_npcs")
	add_to_group("npc")
	original_pos = global_position
	if _animated_sprite:
		_base_sprite_scale = _animated_sprite.scale
		if _animated_sprite.sprite_frames and _animated_sprite.sprite_frames.has_animation("idle"):
			_animated_sprite.play("idle")
	if _speech_label:
		_speech_label.visible = false
	if _interaction_area:
		_interaction_area.body_entered.connect(_on_body_entered)
		_interaction_area.body_exited.connect(_on_body_exited)

	var fm := get_node_or_null("/root/FireManager")
	if fm:
		fm.fire_started.connect(_on_fire_started)
		fm.fire_ended.connect(_on_fire_ended)


func _is_busy_moving() -> bool:
	return is_fleeing or is_going_to_lunch or is_returning


func _physics_process(_delta: float) -> void:
	if is_fleeing:
		_move_to(exit_target, "run")
		if global_position.distance_to(exit_target) < 30.0:
			is_fleeing = false
			velocity = Vector2.ZERO
			visible = false
	elif is_going_to_lunch:
		_move_to(lunch_target, "walk")
		if global_position.distance_to(lunch_target) < 10.0:
			_stop_moving()
			is_going_to_lunch = false
	elif is_returning:
		visible = true
		_move_to(original_pos, "walk")
		if global_position.distance_to(original_pos) < 10.0:
			_stop_moving()
	else:
		velocity = Vector2.ZERO

	move_and_slide()


func start_lunch(_target_pos: Vector2 = Vector2.ZERO) -> void:
	is_going_to_lunch = true
	is_returning = false
	lunch_target = lunch_spot
	if _speech_label:
		_speech_label.text = _HINT_LUNCH
		_speech_label.modulate = Color.WHITE
		_speech_label.visible = true


func end_lunch() -> void:
	is_going_to_lunch = false
	is_returning = true
	if _speech_label:
		_speech_label.visible = false


func _on_fire_started() -> void:
	NpcPhysics.disable_body_collision(self)
	start_fleeing(Vector2(500, 500))


func _on_fire_ended() -> void:
	NpcPhysics.apply_body_collision(self)
	visible = true
	is_fleeing = false
	is_returning = true


func start_fleeing(target_pos: Vector2) -> void:
	if is_fleeing:
		return
	is_fleeing = true
	is_going_to_lunch = false
	is_returning = false
	exit_target = target_pos
	if _speech_label:
		_speech_label.text = "FIRE! RUN!!!"
		_speech_label.modulate = Color.ORANGE_RED
		_speech_label.visible = true
	animate_panic_bounce()


func animate_panic_bounce() -> void:
	if not _animated_sprite:
		return
	if bounce_tween:
		bounce_tween.kill()
	if rotate_tween:
		rotate_tween.kill()
	bounce_tween = create_tween().set_loops()
	bounce_tween.tween_property(_animated_sprite, "scale", _base_sprite_scale * Vector2(1.2, 0.8), 0.1)
	bounce_tween.tween_property(_animated_sprite, "scale", _base_sprite_scale * Vector2(0.8, 1.2), 0.1)
	rotate_tween = create_tween().set_loops()
	rotate_tween.tween_property(_animated_sprite, "rotation_degrees", 15.0, 0.08)
	rotate_tween.tween_property(_animated_sprite, "rotation_degrees", -15.0, 0.08)


func _move_to(target: Vector2, anim_name: String) -> void:
	var direction := global_position.direction_to(target)
	velocity = direction * run_speed
	if _animated_sprite:
		_play_move_anim(anim_name)
		if direction.x != 0.0:
			_animated_sprite.flip_h = direction.x < 0.0


func _play_move_anim(anim_name: String) -> void:
	if not _animated_sprite or not _animated_sprite.sprite_frames:
		return
	if _animated_sprite.sprite_frames.has_animation(anim_name):
		_animated_sprite.play(anim_name)
	elif _animated_sprite.sprite_frames.has_animation("idle"):
		_animated_sprite.play("idle")


func _stop_moving() -> void:
	is_fleeing = false
	is_returning = false
	is_going_to_lunch = false
	velocity = Vector2.ZERO
	if bounce_tween:
		bounce_tween.kill()
		bounce_tween = null
	if rotate_tween:
		rotate_tween.kill()
		rotate_tween = null
	if _animated_sprite:
		_animated_sprite.rotation = 0.0
		_animated_sprite.scale = _base_sprite_scale
		if _animated_sprite.sprite_frames and _animated_sprite.sprite_frames.has_animation("idle"):
			_animated_sprite.play("idle")
	if _speech_label:
		_speech_label.visible = false


func _on_body_entered(body: Node2D) -> void:
	if _is_busy_moving():
		return
	if body.is_in_group("player"):
		player_in_range = true
		_refresh_hint()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if _speech_label:
			_speech_label.visible = false


func _input(event: InputEvent) -> void:
	if _is_busy_moving() or not visible or not player_in_range:
		return
	if event.is_action_pressed("interact"):
		if DialogueManager.try_start(npc_id):
			if _speech_label:
				_speech_label.visible = false


func _process(_delta: float) -> void:
	if _is_busy_moving() or not player_in_range or not visible:
		return
	_refresh_hint()


func _refresh_hint() -> void:
	if not _speech_label:
		return
	if get_tree().root.has_node("DialogueUI"):
		_speech_label.visible = false
		return
	_speech_label.visible = true
	_speech_label.modulate = Color.WHITE
	if not TaskManager.is_timer_active or TaskManager.level_time_passed < TaskManager.LUNCH_START_AT_SECONDS:
		_speech_label.text = _HINT_BUSY
	elif not DialogueManager.has_more_dialogue(npc_id):
		_speech_label.text = _HINT_NOTHING
	else:
		_speech_label.text = _HINT_PRESS_E
