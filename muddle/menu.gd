extends Node2D
func _on_startgame_pressed() -> void:
	get_tree().change_scene_to_file("res://crust.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_save_1_pressed() -> void:
	print("not implemented. yet.")
	pass # Replace with function body.
	
func _on_save_2_pressed() -> void:
	print("not implemented. yet.")
