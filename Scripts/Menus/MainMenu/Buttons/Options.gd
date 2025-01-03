extends Button

var description: String = 'Change the game configurations'
var close_on_select: bool = false

func on_menu_selected() -> void:
	OptionsMenuManager.is_menu_open = true
