extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var map: TileMapLayer = $"../foreground"
@onready var darkness: TileMapLayer = $"../darkness"

#speed of sprite change (pixels/second)
@export var tilt_threshold: float = 100

func _physics_process(delta):
	# a flying drone
	const ACCEL = 600.0 #speeding
	const FRICTION = 150.0 #slowing
	const MAX_SPEED = 200.0 #this is so obvious
	const GRAVITY = 250.0 #down without down press
	const THRUST = -400.0 #up #must be more than gravity or gets stuck digging
	const LIFT_FACTOR = 0.7 #dont go down when moving sideways
	const TERMINAL_VELOCITY_UP = -200
	const TERMINAL_VELOCITY_DOWN = 2000
	#no down
	var dir_x = Input.get_axis("ui_left", "ui_right")
	var is_thrusting = Input.is_action_pressed("ui_up")
	
	#sideways
	if dir_x != 0:
		#move toward full speed
		velocity.x = move_toward(velocity.x, dir_x * MAX_SPEED, ACCEL * delta)
	else:
		#slow down
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	
	#vertical stuffs
	if is_thrusting:
		velocity.y += THRUST * delta
	
	#terminal velocity
	velocity.y = clampf(velocity.y, TERMINAL_VELOCITY_UP, TERMINAL_VELOCITY_DOWN)
	#sideways lift
	var lift = abs(velocity.x) * LIFT_FACTOR
	var effective_gravity = max(0, GRAVITY - lift)
	
	velocity.y += effective_gravity * delta
	
	#stuck
	if is_on_floor():
		velocity.x = 0
	
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = -80 # jump	
	
	#LIGHT
	if darkness:
		darkness.cast_light(global_position, 3)
	#water kills
	var current_grid_pos = map.local_to_map(global_position)
	var tile_id = map.get_cell_source_id(current_grid_pos)
	if tile_id == 3:
		die()
	
	animate()
	
	move_and_slide()
func animate() -> void:
	#right
	if velocity.x > tilt_threshold:
		if sprite.animation != "goingright":
			sprite.play('goingright')
	#left
	elif velocity.x < -tilt_threshold:
		if sprite.animation != "goingleft":
			sprite.play("goingleft")
	#not moving fast
	else:
		if sprite.animation != "drone":
			sprite.play("drone")
func die():
	get_tree().quit()
