extends TextureButton

func _on_button_down():
	GameManager.toggle_pause_game()
