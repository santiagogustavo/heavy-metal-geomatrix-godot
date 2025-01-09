extends Button

@export_file var redirect_to_scene: String

var description = 'Fight to the top against skilled opponents'
var close_on_select = true

func on_menu_selected() -> void:
	LoadingManager.next_scene = redirect_to_scene
	get_tree().change_scene_to_file(Definitions.Scenes.Loading)
