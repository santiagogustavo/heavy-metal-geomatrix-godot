extends Control

@onready var option_button = $HBoxContainer/OptionButton as OptionButton

const WINDOW_MODES: Array[String] = [
	"Fullscreen",
	"Windowed",
	"Borderless Window",
	"Borderless Fullscreen"
]

func _ready():
	add_window_mode_items()
	select_current_window_mode()
	option_button.item_selected.connect(on_window_mode_selected)

func add_window_mode_items() -> void:
	for window_mode in WINDOW_MODES:
		option_button.add_item(window_mode)
		
func select_current_window_mode() -> void:
	var index = -1
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		if DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS) == false:
			index = 0
		else:
			index = 3
	else:
		if DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS) == false:
			index = 1
		else:
			index = 2
	option_button.select(index)

func on_window_mode_selected(index: int) -> void:
	VideoSettingsManager.set_window_mode(index)
