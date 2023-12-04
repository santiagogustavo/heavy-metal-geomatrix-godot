extends TextureButton

@export_file var redirect_to_scene: String

func _on_button_down():
	GameManager.resume_game()
	get_tree().change_scene_to_file(redirect_to_scene)
