extends Node

@onready var window: Window = get_window()
@onready var base_size: Vector2i = window.content_scale_size 

var window_mode: DisplayServer.WindowMode = 1 as DisplayServer.WindowMode
var viewport_width: int = DisplayServer.window_get_size().x
var viewport_height: int = DisplayServer.window_get_size().y

var bloom_enabled: bool = true
var bloom_intensity: float = 0.25

func _init() -> void:
	if OS.has_feature("editor"):
		ProjectSettings.set("display/window/stretch/mode", "viewport")

func center_window():
	var screen_center = DisplayServer.screen_get_size() / 2
	var window_size = get_window().get_size_with_decorations()
	DisplayServer.window_set_position(screen_center - (window_size / 2))

func set_window_size(size: Vector2i) -> void:
	viewport_width = size.x
	viewport_height = size.y
	DisplayServer.window_set_size(size)
	get_viewport().content_scale_size = Vector2i(1280, 720)
	center_window()

func refresh_window() -> void:
	set_window_size(Vector2i(viewport_width, viewport_height))
	center_window()

func set_window_mode(index: int) -> void:
	window_mode = index as DisplayServer.WindowMode
	match index:
		0: # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: # Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2: # Borderless Window
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		3: # Borderless Window
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	refresh_window()

func set_bloom_enabled(enabled: bool) -> void:
	bloom_enabled = enabled

func set_bloom_intensity(intensity: float) -> void:
	bloom_intensity = intensity
