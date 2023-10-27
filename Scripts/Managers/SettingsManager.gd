extends Node

@export var engine_version: String = Engine.get_version_info().string
@export var music_volume: float = 1
@export var sfx_volume: float = 1

var file = ConfigFile.new()
var path = "user://settings.cfg"

func _ready():
	var file_status = file.load(path)
	if file_status == OK:
		#for section in file.get_sections():
			#print_debug(section, file.get_section_keys(section))
		load_audio_settings()
	else:
		initialize_settings_file()

func initialize_settings_file():
	file.set_value("audio", "music_volume", music_volume)
	file.set_value("audio", "sfx_volume", sfx_volume)
	file.save(path)

func load_audio_settings():
	music_volume = file.get_value("audio", "music_volume")
	sfx_volume = file.get_value("audio", "sfx_volume")
