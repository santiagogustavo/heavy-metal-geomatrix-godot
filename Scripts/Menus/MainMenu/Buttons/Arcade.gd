extends Button

@export_file var redirect_to_scene: String

var description = 'Fight to the top against skilled opponents'
var close_on_select = true

func on_menu_selected() -> void:
	SceneManager.load_scene_file(redirect_to_scene)
