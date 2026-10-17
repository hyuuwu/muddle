extends Node

const CONFIG_PATH := "user://config.json"

var settings := {
	"music_volume": 0.8,
	"sound_volume": 0.8,
	"fullscreen": false
}

func _ready() -> void:
	load_config()

func save_config() -> void:
	var file := FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if file == null:
		push_error("couldnt save ur save. have you tried plugging ur ssd in?")
		return

	file.store_string(JSON.stringify(settings, "\t"))
	file.close()

func load_config() -> void:
	if not FileAccess.file_exists(CONFIG_PATH):
		save_config() # cria o arquivo com os valores padrão
		return

	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file == null:
		push_error("Não foi possível ler config.json")
		return

	var data = JSON.parse_string(file.get_as_text())
	file.close()

	if data is Dictionary:
		settings.merge(data, true)
	else:
		push_warning("config.json inválido; usando valores padrão.")
