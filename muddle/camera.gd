extends Camera2D

@export var drone:CharacterBody2D
@export var intro_spot:Marker2D

var is_following:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if intro_spot:
		global_position = intro_spot.global_position
	await get_tree().create_timer(3.0).timeout
	if drone:
		global_position = drone.global_position
		is_following=true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_following and drone:
		global_position = drone.global_position
