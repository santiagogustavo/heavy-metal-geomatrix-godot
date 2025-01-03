extends Button

var description: String = 'Exit to desktop'
var close_on_select: bool = true

func on_menu_selected() -> void:
	get_tree().quit()
