extends Control

var text = [
	"Clanker.",
	"Buy or get out.",
	"Can you stop spinning for a second?",
	"How about that thing i lent you?",
	"I want my 20 bugs back. You still own me."
]

func _on_button_pressed() -> void:
	var random_dialogue = text.pick_random()

	$Label.text = random_dialogue
	$Label.show()
	$Timer.start()


func _on_timer_timeout() -> void:
	$Label.hide()
