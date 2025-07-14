extends Node

func vibrate_controller(
	device: int,
	weak_magnitude: float,
	strong_magnitude: float,
	duration: float = 0
) -> void:
	if !InputSettingsManager.vibration_enabled:
		return
	Input.start_joy_vibration(device, weak_magnitude, strong_magnitude, duration)

func stop_vibrate_controller(device: int) -> void:
	if !InputSettingsManager.vibration_enabled:
		return
	Input.stop_joy_vibration(device)
