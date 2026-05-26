extends CharacterBody2D

# --- 1. Variables for easy adjustment in the Inspector ---
@export var speed: float = 250.0        # Movement speed
@export var acceleration: float = 0.2    # Acceleration (lower value = more "ice skating" feel)
@export var friction: float = 0.2        # Friction (how fast the character stops)

var can_move: bool = true

# --- 2. Child node references (Names must match your scene tree exactly) ---
@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer

func _physics_process(_delta: float) -> void:
	# Block all movement when a task is active
	if not can_move:
		velocity = velocity.lerp(Vector2.ZERO, friction)
		anim_player.play("idle")
		move_and_slide()
		return
	
	# 3. Get input direction (WASD or Arrow keys)
	# Ensure you have configured these four actions in "Project Settings -> Input Map"
	var input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	# 4. Handle movement logic
	if input_direction != Vector2.ZERO:
		# --- Moving ---
		# Use lerp for smooth acceleration
		velocity = velocity.lerp(input_direction * speed, acceleration)
		
		# Play walking animation
		anim_player.play("walk")
		
		# Handle horizontal flipping based on X-axis direction
		if input_direction.x < 0:
			sprite.flip_h = false   # Moving left
		elif input_direction.x > 0:
			sprite.flip_h = true    # Moving right
			
	else:
		# --- Standing still ---
		# Use lerp for smooth deceleration (inertia)
		velocity = velocity.lerp(Vector2.ZERO, friction)
		
		# Play idle animation
		anim_player.play("idle")

	# 5. Execute physics movement
	move_and_slide()
