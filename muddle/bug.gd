
extends CharacterBody2D

@export var fly_speed: float = 35.0
@export var gravity: float = 180.0
@export var jump_force: float = -85.0
@export var flying_chance: float = 0.7

var flying: bool = true
var direction: Vector2 = Vector2.ZERO
var change_timer: float = 0.0

func _ready() -> void:
	pick_behavior()

func _physics_process(delta: float) -> void:
	change_timer -= delta

	if change_timer <= 0:
		pick_behavior()

	if flying:
		velocity = direction * fly_speed
	else:
		velocity.y += gravity * delta
		velocity.x = direction.x * fly_speed

		if is_on_floor():
			velocity.y = jump_force

	move_and_slide()

	# Bounce off cave walls
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		var normal = collision.get_normal()

		if flying:
			direction = direction.bounce(normal).normalized()
			velocity = direction * fly_speed
		else:
			direction.x *= -1.0

		change_timer = randf_range(0.5, 1.5)

func pick_behavior() -> void:
	change_timer = randf_range(1.0, 3.0)
	flying = randf() < flying_chance

	if flying:
		direction = Vector2(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		).normalized()
	else:
		direction = Vector2(
			[-1.0, 1.0].pick_random(),
			0.0
		)
#func _draw() -> void: #oh why didnt u delet- if needed.
#	draw_rect(Rect2(-4, -4, 8, 8), Color.RED)
