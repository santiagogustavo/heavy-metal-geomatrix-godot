extends Node

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_screenshot"):
		await RenderingServer.frame_post_draw
		var screenshot = get_viewport().get_texture().get_image()
		var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
		screenshot.save_png("user://" + timestamp + ".png") 

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
