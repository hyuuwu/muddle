extends Control

var bugs_eaten = 0
var text = [
	"Clanker.",
	"Buy or get out.",
	"Can you stop spinning for a second?",
	"How about that thing i lent you?",
	"I want my 20 bugs back. You still own me."
]
func _ready():
	load_game()
	$Label2.text = "Bugs: %d" % bugs_eaten
	
var advices = [
	"Caution going east. Heard the bats attack you.",
	"*cough* Dont touch the water.",
	"Rats? They are your friend. Dont kill them."
]
func _on_button_pressed() -> void:
	var random_dialogue = text.pick_random()

	$Label.text = random_dialogue
	$Label.show()
	$Timer.start()


func _on_timer_timeout() -> void:
	$Label.hide()

func save_game() -> void:
	var file = FileAccess.open("user://savefilepleasedontmodify.lsblk", FileAccess.WRITE)

	if file:
		file.store_32(bugs_eaten)
		file.close()
	else:
		print("Save error: ", FileAccess.get_open_error())

func load_game() -> void:
	if FileAccess.file_exists("user://savefilepleasedontmodify.lsblk"):
		var file = FileAccess.open("user://savefilepleasedontmodify.lsblk", FileAccess.READ)

		if file:
			bugs_eaten = file.get_32()
			file.close()
			print("Loaded! Bugs eaten: ", bugs_eaten)



func _on_button_2_pressed() -> void:
	if bugs_eaten < 20:
		$Label.text = "Poor. Come back with 20 bugs."
		$Label.show()
		$Timer.start()
		return

	# Charge the player 20 bugs
	bugs_eaten -= 20

	# Pick random advice
	var rand = advices.pick_random()
	$Label.text = rand

	# Update the counter
	$Label2.text = "Bugs: %d" % bugs_eaten

	# Save the new balance
	save_game()

	# Show advice temporarily
	$Label.show()
	$Timer.start()

		
		
