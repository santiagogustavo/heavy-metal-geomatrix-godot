extends Node

@export var engine_version: String = Engine.get_version_info().string

var audio_volumes: Dictionary = {
	"Master": 1,
	"UI": 1,
	"Music": 1,
	"Effects": 1,
}

var file = ConfigFile.new()
var path = "user://settings.cfg"

func _ready():
	var file_status = file.load(path)
	if file_status == OK:
		#for section in file.get_sections():
			#print_debug(section, file.get_section_keys(section))
		load_audio_settings()
		load_video_settings()
	else:
		save_settings()

func save_settings():
	save_audio_settings()
	save_video_settings()
	save_settings_file()

func load_audio_settings():
	audio_volumes["Master"] = file.get_value("audio", "master_volume", audio_volumes["Master"])
	audio_volumes["UI"] = file.get_value("audio", "ui_volume", audio_volumes["UI"])
	audio_volumes["Music"] = file.get_value("audio", "music_volume", audio_volumes["Music"])
	audio_volumes["Effects"] = file.get_value("audio", "sfx_volume", audio_volumes["Effects"])
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(audio_volumes["Master"]))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("UI"), linear_to_db(audio_volumes["UI"]))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(audio_volumes["Music"]))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), linear_to_db(audio_volumes["Effects"]))

func load_video_settings():
	VideoSettingsManager.set_window_mode(file.get_value("video", "window_mode", VideoSettingsManager.window_mode))
	var resolution = file.get_value("video", "resolution", VideoSettingsManager.resolution)
	VideoSettingsManager.set_window_size(resolution if typeof(resolution) == TYPE_VECTOR2I else str_to_var(resolution))
	
func save_audio_settings():
	file.set_value("audio", "master_volume", audio_volumes["Master"])
	file.set_value("audio", "ui_volume", audio_volumes["UI"])
	file.set_value("audio", "music_volume", audio_volumes["Music"])
	file.set_value("audio", "sfx_volume", audio_volumes["Effects"])

func save_video_settings():
	file.set_value("video", "window_mode", VideoSettingsManager.window_mode)
	file.set_value("video", "resolution", var_to_str(VideoSettingsManager.resolution))
	
func save_settings_file():
	file.save(path)
