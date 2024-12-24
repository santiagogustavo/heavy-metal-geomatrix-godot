extends Node
class_name PlayerInputManager

func should_compute_player_input() -> bool:
	return GameManager.is_game_paused || DebugMenuManager.is_menu_open
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
