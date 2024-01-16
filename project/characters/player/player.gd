extends CharacterBody2D

signal life_changed
signal dead

const run_speed = 400
const gravity = 850

# Player State
enum {IDLE, RUN, BOOST, DEAD}

var state
var anim
var new_anim
var life = 3


func _ready():
	change_state(IDLE)

func start(pos):
	position = pos
	show()
	life = 3
	emit_signal('life_changed', life)
	change_state(IDLE)

func change_state(new_state):
	state = new_state
	print("State changing to: ", state)
	match state:
		IDLE:
			new_anim = 'IDLE'
		RUN:
			new_anim = 'RUN'
		BOOST:
			new_anim = 'RUN'
		DEAD:
			hide()
			emit_signal('dead')

func get_input():
	velocity.x = 0
	var right = Input.is_action_pressed('RIGHT')
	var left = Input.is_action_pressed('LEFT')
	var down = Input.is_action_pressed('DOWN')
	var up = Input.is_action_pressed("UP")
	var dig_left = Input.is_action_just_pressed("DIG_LEFT")
	var dig_right = Input.is_action_just_pressed("DIG_RIGHT")
	# TODO add a BOOST speed
	var boost =  Input.is_action_pressed("BOOST")
	
	if right:
		velocity.x += run_speed
		$Sprite2D.flip_h = false
	if left:
		velocity.x -= run_speed
		$Sprite2D.flip_h = true

	if state in [IDLE] and velocity.x != 0:
		change_state(RUN)
	if state == RUN and velocity.x == 0:
		change_state(IDLE)


func _physics_process(delta):
	velocity.y += gravity * delta
	get_input()
	if new_anim != anim:
		anim = new_anim
		$AnimationPlayer.play(anim)

	set_velocity(velocity)
	set_up_direction(Vector2(0, -1))
	move_and_slide()
	velocity = velocity

	# Fall down hole
	if position.y > 780:
		change_state(DEAD)
