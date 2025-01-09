extends HBoxContainer

@onready var option_button = $OptionButton as OptionButton

var RESOLUTION_DICTIONARY: Dictionary = {
	"640x480": Vector2i(640, 480),
	"1280x720": Vector2i(1280, 720),
	"1366x768": Vector2i(1366, 768),
	"1920x1080": Vector2i(1920, 1080),
	"2560x1440": Vector2i(2560, 1440),
}

func _ready():
	get_current_resolution_and_add()
	add_resolution_mode_items()
	select_current_resolution()
	option_button.item_selected.connect(on_resolution_mode_selected)
	
func get_current_resolution_and_add() -> void:
	var current_resolution = DisplayServer.window_get_size()
	var key = str(current_resolution[0]) + "x" + str(current_resolution[1])
	if !RESOLUTION_DICTIONARY.has(key):
		RESOLUTION_DICTIONARY[key] = current_resolution

func select_current_resolution() -> void:
	var current_resolution = DisplayServer.window_get_size()
	for index in RESOLUTION_DICTIONARY.values().size():
		if current_resolution == RESOLUTION_DICTIONARY.values()[index]:
			option_button.select(index)

func add_resolution_mode_items() -> void:
	for resolution_mode_key in RESOLUTION_DICTIONARY:
		option_button.add_item(resolution_mode_key)

func on_resolution_mode_selected(index: int) -> void:
	VideoSettingsManager.set_window_size(RESOLUTION_DICTIONARY.values()[index])
	VideoSettingsManager.center_window()
