extends Node2D
func _on_startgame_pressed() -> void:
	get_tree().change_scene_to_file("res://crust.tscn")
# why change name to menu, emnu was good fam 
func _on_quit_pressed() -> void:
	get_tree().quit()
