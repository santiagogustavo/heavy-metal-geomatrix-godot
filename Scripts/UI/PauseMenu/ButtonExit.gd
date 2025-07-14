extends Button

func _ready() -> void:
	connect("button_down", exit_to_main_menu)

func exit_to_main_menu() -> void:
	GameManager.resume_game()
	GameManager.end_match()
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
