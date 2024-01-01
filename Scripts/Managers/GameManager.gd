extends Node

var sun: DirectionalLight3D

var current_level_config: LevelConfig = LevelConfig.new()
var current_scene_type: Definitions.SceneType = Definitions.SceneType.Intro

var engine_version = Engine.get_version_info().string
var is_game_paused = false

var players: Array[Player] = []

func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS
	lock_cursor()

func _process(_delta):
	if Input.is_action_just_pressed("pause") and current_scene_type == Definitions.SceneType.LocalGame:
		toggle_pause_game()

func lock_cursor():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func unlock_cursor():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func resume_game():
	is_game_paused = false
	lock_cursor()
	get_tree().paused = false

func pause_game():
	is_game_paused = true
	unlock_cursor()
	get_tree().paused = true

func toggle_pause_game():
	if get_tree().paused:
		resume_game()
	else:
		pause_game()

func set_sun(new_sun: DirectionalLight3D):
	sun = new_sun

func remove_sun():
	sun = null

func get_player_one() -> Player:
	return players[0] if players.size() > 0 else null

func add_player(player: Player):
	players.append(player)

func remove_player(rid: RID):
	var pop_index = -1
	for i in range(players.size()):
		if players[i].get_rid() == rid:
			pop_index = i
			break
	players.pop_at(pop_index)
