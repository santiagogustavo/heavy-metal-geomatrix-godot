extends AudioStreamPlayer2D

func _init() -> void:
	process_mode = PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	AudioServer.set_bus_effect_enabled(7, 1, GameManager.is_game_paused) # Lowpass
	AudioServer.set_bus_effect_enabled(7, 2, GameManager.is_game_paused) # Amplify
