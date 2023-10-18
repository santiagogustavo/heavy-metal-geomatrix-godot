extends Node

@export var current_level_config: LevelConfig = LevelConfig.new()
var is_game_paused = false

func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		toggle_pause_game()

func toggle_pause_game():
	if get_tree().paused:
		is_game_paused = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		is_game_paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	get_tree().paused = is_game_paused
