extends Area2D

@export var shop_scene: PackedScene

@onready var label: Label = $Label

var player_nearby := false

func _ready():
	label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "drone":
		player_nearby = true
		label.visible = true

func _on_body_exited(body):
	if body.name == "drone":
		player_nearby = false
		label.visible = false

func _process(_delta):
	if player_nearby and Input.is_action_just_pressed("interact"):
		if shop_scene != null:
			get_tree().change_scene_to_packed.call_deferred(shop_scene)
