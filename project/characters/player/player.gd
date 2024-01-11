extends CharacterBody2D

# CODE FOR GODOT 4.2.1 - SK7LL

# CHARACTER-VALUES
const UP : Vector2 = Vector2(0, -1)
const GRAVITY : float = 40
const SPEED : float = 200

# CHARACTER-MOTION
var current_speed : float = SPEED

# CHARACTER
@onready var character = $Sprite2D
@onready var characterAnimation = $AnimationPlayer

func _physics_process(_delta):
	velocity.y += GRAVITY

	# CHARACTER-INPUT
	if Input.is_action_pressed("RIGHT"):
		velocity.x = current_speed
		character.flip_h = false
	elif Input.is_action_pressed("LEFT"):
		velocity.x = -current_speed
		character.flip_h = true
	else:
		velocity.x = 0

	# CHARACTER FALL OR CLIMB
	#if is_on_floor():
		#if velocity.y < 0:
			#characterAnimation.play("CLIMB")
		#else:
			#characterAnimation.play("FALL")
		
	# CHARACTER-ANIMATION
	if velocity.x != 0:
		print("running")
		characterAnimation.play("RUN")
	elif velocity.x == 0:
		characterAnimation.play("IDLE")
		
	move_and_slide()
