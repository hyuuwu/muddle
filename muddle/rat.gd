
extends CharacterBody2D

@export var speed: float = 40.0
@export var muds_source_id: int = 0
@export var cave_map: TileMapLayer

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer

var direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	timer.timeout.connect(change_direction)
	change_direction()


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Horizontal movement only
	velocity.x = direction.x * speed

	move_and_slide()

func can_walk(pos: Vector2) -> bool:
	if cave_map == null:
		return false

	var local_pos = cave_map.to_local(pos)
	var cell = cave_map.local_to_map(local_pos)

	return cave_map.get_cell_source_id(cell) == muds_source_id


func change_direction() -> void:
	var directions = [
		Vector2.UP,
		Vector2.DOWN,
		Vector2.LEFT,
		Vector2.RIGHT,
		Vector2.ZERO
	]

	direction = directions.pick_random()
	timer.start(randf_range(0.8, 2.5))
''
