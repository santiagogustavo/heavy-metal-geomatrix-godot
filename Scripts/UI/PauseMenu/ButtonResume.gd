extends Button

var has_focused: bool = false

func _ready() -> void:
	connect("button_down", resume_game)

func _process(_delta: float) -> void:
	if GameManager.is_game_paused and !has_focused:
		has_focused = true
		grab_focus()
	elif !GameManager.is_game_paused:
		has_focused = false

func resume_game() -> void:
	GameManager.toggle_pause_game()
