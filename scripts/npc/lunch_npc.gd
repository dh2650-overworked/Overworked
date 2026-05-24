extends CharacterBody2D

const _HINT_BUSY := "Busy right now. Let's chat later."
const _HINT_PRESS_E := "Press E to talk."
const _HINT_NOTHING := "Nothing else to talk about for now."

@export var npc_id: String = ""

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _speech_label: Label = $Label
@onready var _interaction_area: Area2D = $InteractionArea

var player_in_range: bool = false


func _ready() -> void:
	add_to_group("lunch_npcs")
	if _animated_sprite and _animated_sprite.sprite_frames:
		if _animated_sprite.sprite_frames.has_animation("idle"):
			_animated_sprite.play("idle")
	if _speech_label:
		_speech_label.visible = false
	if _interaction_area:
		_interaction_area.body_entered.connect(_on_body_entered)
		_interaction_area.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		_refresh_hint()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if _speech_label:
			_speech_label.visible = false


func _input(event: InputEvent) -> void:
	if not visible or not player_in_range:
		return
	if event.is_action_pressed("interact"):
		if DialogueManager.try_start(npc_id):
			if _speech_label:
				_speech_label.visible = false


func _process(_delta: float) -> void:
	if player_in_range and visible:
		_refresh_hint()


func _refresh_hint() -> void:
	if not _speech_label:
		return
	if get_tree().root.has_node("DialogueUI"):
		_speech_label.visible = false
		return
	_speech_label.visible = true
	if not TaskManager.is_timer_active or TaskManager.level_time_passed < TaskManager.LUNCH_START_AT_SECONDS:
		_speech_label.text = _HINT_BUSY
	elif not DialogueManager.has_more_dialogue(npc_id):
		_speech_label.text = _HINT_NOTHING
	else:
		_speech_label.text = _HINT_PRESS_E
