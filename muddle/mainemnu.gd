extends Node2D

func _on_startgame_pressed() -> void:
	get_tree().change_scene_to_file("res://crust.tscn")
	pass # Replace with function body.


func _on_options_pressed() -> void:
	print("bruh aint no options yet")
	pass # Replace with function body.


func _on_qut_pressed() -> void:
	get_tree().quit()
