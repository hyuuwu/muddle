extends Node2D
func _on_startgame_pressed() -> void:
	get_tree().change_scene_to_file("res://crust.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
