extends TextureRectButton

@export_file var redirect_to_scene: String

var description = 'The original arcade version.'
var close_on_select = true

func _on_button_pressed():
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file(redirect_to_scene)
