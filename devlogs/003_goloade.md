# Devlog: 003

## 1. Date and Session Information:

**Date:** April 22nd, 2024

**Session Focus:** Work on Player scripting

## 2. Overview:

In today's session, we focused on implementing functionality for the Player character in the game. The main goal was to enhance the Player script to allow for digging left and right to remove blocks from the environment.

```gdscript
extends CharacterBody2D

signal life_changed
signal dead

const run_speed = 400
const gravity = 850

# Player State
enum {IDLE, RUN, BOOST, CLIMB, FALL, DEAD}
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
    CLIMB:
      new_anim = 'CLIMB'
    FALL:
      new_anim = 'FALL'
    DEAD:
      hide()
      emit_signal('dead')

func remove_block(direction: int):
  var player_tile_pos = $TileMap.world_to_map(global_position)  # Convert player position to tile coordinates
  var target_tile_pos = Vector2.ZERO
  if direction == 1:  # Digging left
    target_tile_pos = player_tile_pos + Vector2(-1, 0)
  elif direction == 2:  # Digging right
    target_tile_pos = player_tile_pos + Vector2(1, 0)

  if $TileMap.cell_size.x > 0 and $TileMap.cell_size.y > 0:  # Ensure tile map is properly configured
    if $TileMap.get_cellv(target_tile_pos) != -1:  # Check if there's a block at the target tile
      $TileMap.set_cellv(target_tile_pos, -1)  # Set the cell to -1 (empty) to remove the block
    else:
      print("No block to remove in the specified direction")
  else:
    print("TileMap cell size not properly configured")

func get_input():
  velocity.x = 0

  # General directions
  var right = Input.is_action_pressed('RIGHT')
  var left = Input.is_action_pressed('LEFT')
  var down = Input.is_action_pressed('DOWN')
  var up = Input.is_action_pressed("UP")

  # Digging actions
  var dig_left = Input.is_action_just_pressed("DIG_LEFT")
  var dig_right = Input.is_action_just_pressed("DIG_RIGHT")

  # Add BOOST speed to Player
  var boost =  Input.is_action_pressed("BOOST")

  # Climbing up ladder
  if state == CLIMB:
    if up:
      velocity.y -= run_speed  # Move upwards on ladder
    elif down:
      velocity.y += run_speed  # Move downwards on ladder
    else:
      velocity.y = 0  # Stop vertical movement if no input

  # Add Falling from height
  if not is_on_floor() and not state == CLIMB:  # Check if not on floor and not climbing
    change_state(FALL)  # Change state to FALL

  if dig_left:
    remove_block(1)  # Remove block to the left
  if dig_right:
    remove_block(2)  # Remove block to the right

  if right:
    if boost:  # Check if BOOST action is pressed
      velocity.x += run_speed * 2  # Increase speed if BOOST is pressed
    else:
      velocity.x += run_speed
    $Sprite2D.flip_h = false
  if left:
    if boost:  # Check if BOOST action is pressed
      velocity.x -= run_speed * 2  # Increase speed if BOOST is pressed
    else:
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

  # Check if player is on the floor
  if is_on_floor():
    if state == FALL:
      change_state(IDLE)  # Change state to IDLE when player lands back on the ground

  # Fall down hole
  if position.y > 780:
    change_state(DEAD)

```

