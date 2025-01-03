extends TextureButton

@export_file var redirect_to_scene: String

var description: String = 'Fight to the top against skilled opponents'
var close_on_select: bool = true

func _on_button_down():
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file(redirect_to_scene)
