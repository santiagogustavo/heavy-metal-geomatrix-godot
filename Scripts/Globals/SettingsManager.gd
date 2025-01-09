extends Node

@export var engine_version: String = Engine.get_version_info().string

var file = ConfigFile.new()
var path = "user://settings.cfg"

func _ready():
	var file_status = file.load(path)
	if file_status == OK:
		load_audio_settings()
		load_video_settings()
		load_input_settings()
		load_gameplay_settings()
	else:
		save_settings()

func save_settings():
	save_audio_settings()
	save_video_settings()
	save_input_settings()
	save_gameplay_settings()
	save_settings_file()

func load_audio_settings():
	AudioSettingsManager.set_volume("Master", file.get_value("audio", "master_volume", AudioSettingsManager.volumes["Master"]))
	AudioSettingsManager.set_volume("UI", file.get_value("audio", "ui_volume", AudioSettingsManager.volumes["UI"]))
	AudioSettingsManager.set_volume("Music", file.get_value("audio", "music_volume", AudioSettingsManager.volumes["Music"]))
	AudioSettingsManager.set_volume("Effects", file.get_value("audio", "sfx_volume", AudioSettingsManager.volumes["Effects"]))

func load_video_settings():
	VideoSettingsManager.set_window_mode(file.get_value("video", "window_mode", VideoSettingsManager.window_mode))
	VideoSettingsManager.set_window_size(
		Vector2i(
			file.get_value("video", "viewport_width", VideoSettingsManager.viewport_width),
			file.get_value("video", "viewport_height", VideoSettingsManager.viewport_height),
		)
	)

func load_input_settings():
	InputSettingsManager.set_look_smoothing_enabled(file.get_value("input", "look_smoothing_enabled", InputSettingsManager.look_smoothing_enabled))
	InputSettingsManager.set_look_smoothing_intensity(file.get_value("input", "look_smoothing_intensity", InputSettingsManager.look_smoothing_intensity))
	InputSettingsManager.set_mouse_horizontal_sensitivity(file.get_value("input", "mouse_horizontal_sensitivity", InputSettingsManager.mouse_horizontal_sensitivity))
	InputSettingsManager.set_mouse_vertical_sensitivity(file.get_value("input", "mouse_vertical_sensitivity", InputSettingsManager.mouse_vertical_sensitivity))
	InputSettingsManager.set_vibration_enabled(file.get_value("input", "vibration_enabled", InputSettingsManager.vibration_enabled))
	InputSettingsManager.set_stick_horizontal_sensitivity(file.get_value("input", "stick_horizontal_sensitivity", InputSettingsManager.stick_horizontal_sensitivity))
	InputSettingsManager.set_stick_vertical_sensitivity(file.get_value("input", "stick_vertical_sensitivity", InputSettingsManager.stick_vertical_sensitivity))

func load_gameplay_settings():
	GameplaySettingsManager.set_fov(file.get_value("gameplay", "fov", GameplaySettingsManager.fov))
	GameplaySettingsManager.set_crosshair_style(file.get_value("gameplay", "crosshair_style", GameplaySettingsManager.crosshair_style))
	GameplaySettingsManager.set_crosshair_scale(file.get_value("gameplay", "crosshair_scale", GameplaySettingsManager.crosshair_scale))
	GameplaySettingsManager.set_crosshair_color_r(file.get_value("gameplay", "crosshair_color_r", GameplaySettingsManager.crosshair_color_r))
	GameplaySettingsManager.set_crosshair_color_g(file.get_value("gameplay", "crosshair_color_g", GameplaySettingsManager.crosshair_color_g))
	GameplaySettingsManager.set_crosshair_color_b(file.get_value("gameplay", "crosshair_color_b", GameplaySettingsManager.crosshair_color_b))
	GameplaySettingsManager.set_crosshair_color_a(file.get_value("gameplay", "crosshair_color_a", GameplaySettingsManager.crosshair_color_a))

func save_audio_settings():
	file.set_value("audio", "master_volume", AudioSettingsManager.volumes["Master"])
	file.set_value("audio", "ui_volume", AudioSettingsManager.volumes["UI"])
	file.set_value("audio", "music_volume", AudioSettingsManager.volumes["Music"])
	file.set_value("audio", "sfx_volume", AudioSettingsManager.volumes["Effects"])

func save_video_settings():
	file.set_value("video", "window_mode", VideoSettingsManager.window_mode)
	file.set_value("video", "viewport_width", VideoSettingsManager.viewport_width)
	file.set_value("video", "viewport_height", VideoSettingsManager.viewport_height)
	
func save_input_settings():
	file.set_value("input", "look_smoothing_enabled", InputSettingsManager.look_smoothing_enabled)
	file.set_value("input", "look_smoothing_intensity", InputSettingsManager.look_smoothing_intensity)
	file.set_value("input", "mouse_horizontal_sensitivity", InputSettingsManager.mouse_horizontal_sensitivity)
	file.set_value("input", "mouse_vertical_sensitivity", InputSettingsManager.mouse_vertical_sensitivity)
	file.set_value("input", "vibration_enabled", InputSettingsManager.vibration_enabled)
	file.set_value("input", "stick_horizontal_sensitivity", InputSettingsManager.stick_horizontal_sensitivity)
	file.set_value("input", "stick_vertical_sensitivity", InputSettingsManager.stick_vertical_sensitivity)
	
func save_gameplay_settings():
	file.set_value("gameplay", "fov", GameplaySettingsManager.fov)
	file.set_value("gameplay", "crosshair_style", GameplaySettingsManager.crosshair_style)
	file.set_value("gameplay", "crosshair_scale", GameplaySettingsManager.crosshair_scale)
	file.set_value("gameplay", "crosshair_color_r", GameplaySettingsManager.crosshair_color_r)
	file.set_value("gameplay", "crosshair_color_g", GameplaySettingsManager.crosshair_color_g)
	file.set_value("gameplay", "crosshair_color_b", GameplaySettingsManager.crosshair_color_b)
	file.set_value("gameplay", "crosshair_color_a", GameplaySettingsManager.crosshair_color_a)
	
func save_settings_file():
	file.save(path)
