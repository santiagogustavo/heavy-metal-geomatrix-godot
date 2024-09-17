extends Node

var window_mode: = 1
var viewport_width: int = DisplayServer.window_get_size().x
var viewport_height: int = DisplayServer.window_get_size().y

func center_window():
	var center_screen = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() /2
	var window_size = get_window().get_size_with_decorations()
	var new_window_position = center_screen - window_size /2
	get_window().set_position(new_window_position) 

func set_window_size(size: Vector2i) -> void:
	viewport_width = size.x
	viewport_height = size.y
	#get_viewport().content_scale_size = size
	DisplayServer.window_set_size(size)
	center_window()

func set_window_mode(index: int) -> void:
	window_mode = index
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
