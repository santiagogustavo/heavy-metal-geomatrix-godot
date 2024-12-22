extends Node

var volumes: Dictionary = {
	"Master": 1,
	"UI": 1,
	"Music": 1,
	"Effects": 1,
}


func set_volume_index(bus_index: int, volume: float) -> void:
	volumes[AudioServer.get_bus_name(bus_index)] = volume
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume))

func set_volume(bus_name: String, volume: float) -> void:
	volumes[bus_name] = volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), linear_to_db(volume))
