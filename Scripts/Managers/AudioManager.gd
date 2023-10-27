extends Node

func _process(_delta):
	AudioServer.set_bus_volume_db(6, linear_to_db(SettingsManager.music_volume))
	AudioServer.set_bus_volume_db(9, linear_to_db(SettingsManager.sfx_volume))
