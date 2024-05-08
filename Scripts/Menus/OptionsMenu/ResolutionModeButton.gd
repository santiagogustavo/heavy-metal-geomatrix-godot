extends Control

@onready var option_button = $HBoxContainer/OptionButton as OptionButton

const RESOLUTION_DICTIONARY: Dictionary = {
	"1280x720": Vector2i(1280, 720),
	"1366x768": Vector2i(1366, 768),
	"1920x1080": Vector2i(1920, 1080),
	"2560x1440": Vector2i(2560, 1440),
}

func _ready():
	add_resolution_mode_items()
	option_button.item_selected.connect(on_resolution_mode_selected)

func add_resolution_mode_items() -> void:
	for resolution_mode_key in RESOLUTION_DICTIONARY:
		option_button.add_item(resolution_mode_key)

func on_resolution_mode_selected(index: int) -> void:
	DisplayServer.window_set_size(RESOLUTION_DICTIONARY.values()[index])
