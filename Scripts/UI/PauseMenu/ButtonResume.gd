extends Button

func _ready() -> void:
	connect("button_down", resume_game)

func resume_game() -> void:
	GameManager.toggle_pause_game()
