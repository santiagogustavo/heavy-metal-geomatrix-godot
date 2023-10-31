extends Node

func _ready():
	update_audio_server()

func _process(_delta):
	update_audio_server()

func update_audio_server():
	AudioServer.set_bus_volume_db(6, linear_to_db(SettingsManager.music_volume))
	AudioServer.set_bus_volume_db(9, linear_to_db(SettingsManager.sfx_volume))
