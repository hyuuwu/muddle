extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_startgame_pressed() -> void:
	get_tree().change_scene_to_file("res://crust.tscn")
	pass # Replace with function body.


func _on_options_pressed() -> void:
	print("bruh aint no options yet")
	pass # Replace with function body.


func _on_qut_pressed() -> void:
	get_tree().quit()
