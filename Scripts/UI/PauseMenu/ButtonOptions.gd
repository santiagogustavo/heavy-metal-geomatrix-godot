extends Button

func _ready() -> void:
	connect( "button_down", open_options_menu)

func open_options_menu() -> void:
	OptionsMenuManager.is_menu_open = true
