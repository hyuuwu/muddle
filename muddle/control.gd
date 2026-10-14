extends CanvasLayer

@onready var label: Label = $Panel/MarginContainer/VBoxContainer/Label

func update_bug_count(bugs_eaten: int) -> void:
	label.text = "Bugs:" + str(bugs_eaten)
