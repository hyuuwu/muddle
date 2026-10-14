extends Node2D
func _on_startgame_pressed() -> void:
	get_tree().change_scene_to_file("res://crust.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()


# settings_manager.gd

const SAVE_PATH := "user://settings.cfg"

# Default settings (the fallback when the file is missing or corrupted)
var default_settings := {
	"video": { "fullscreen": false, "vsync": true },
	"audio": { "master_volume": 0.8 },
}

func save_settings(settings: Dictionary) -> void:
	var config := ConfigFile.new()
	for section in settings:
		for key in settings[section]:
			config.set_value(section, key, settings[section][key])

	var err := config.save(SAVE_PATH)          # always check the return value
	if err != OK:
		printerr("Failed to save settings: %s" % error_string(err))

func load_settings() -> Dictionary:
	var config := ConfigFile.new()
	# No file yet? Return the defaults (first launch, for example)
	if config.load(SAVE_PATH) != OK:
		return default_settings.duplicate(true)

	var result := default_settings.duplicate(true)
	for section in default_settings:
		for key in default_settings[section]:
			# Passing a default as the third argument makes missing keys safe
			result[section][key] = config.get_value(section, key, default_settings[section][key])
	return result


func _on_save_1_pressed() -> void:
	print("not implemented. yet.")
	pass # Replace with function body.
	
func _on_save_2_pressed() -> void:
	print("not implemented. yet.")
