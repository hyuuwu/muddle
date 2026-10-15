func _ready():
	# SAVE
	var file = FileAccess.open("user://savefilepleasedontmodify.lsblk", FileAccess.WRITE)

	if file:
		file.store_string("bruh")
		file.close()
		print("Saved successfully!")
	else:
		print("Error saving!")

	# LOAD
	if FileAccess.file_exists("user://savefilepleasedontmodify.lsblk"):
		var save_file = FileAccess.open("user://savefilepleasedontmodify.lsblk", FileAccess.READ)

		if save_file:
			var content = save_file.get_as_text()
			print(content)
			save_file.close()
