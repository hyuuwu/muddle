extends Camera2D

@export var drone:CharacterBody2D
@export var intro_spot:Marker2D
@export var inventory_node: CanvasLayer

var is_following:bool = false
var can_skip:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if intro_spot:
		global_position = intro_spot.global_position
	await get_tree().create_timer(3.0).timeout
	can_skip=false
	if drone:
		is_following=true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_following and drone:
		global_position = drone.global_position
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if can_skip:
			is_following = true
		else:
			if inventory_node:
				inventory_node.visible = not inventory_node.visible
