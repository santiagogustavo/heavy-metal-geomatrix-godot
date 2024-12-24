extends Node

signal pause
signal resume

var current_level_config: LevelConfig = LevelConfig.new()
var current_scene_type: Definitions.SceneType = Definitions.SceneType.Intro

var engine_version: String = Engine.get_version_info().string

# Gameplay variables
var is_game_paused: bool = false
var current_match: MatchManager
var players: Array[Player] = []

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func create_match(new_match: MatchManager) -> void:
	current_match = new_match
	get_tree().root.add_child.call_deferred(current_match)

func end_match() -> void:
	get_tree().root.remove_child.call_deferred(current_match)
	current_match.queue_free()
	current_match = null

func lock_cursor() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func unlock_cursor() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func resume_game() -> void:
	if !is_game_paused:
		return
	is_game_paused = false
	lock_cursor()
	get_tree().paused = false
	resume.emit()

func pause_game() -> void:
	if is_game_paused:
		return
	is_game_paused = true
	unlock_cursor()
	get_tree().paused = true
	pause.emit()

func toggle_pause_game() -> void:
	if get_tree().paused:
		resume_game()
	else:
		pause_game()

func get_player_one() -> Player:
	return players[0] if players.size() > 0 else null

func add_player(player: Player):
	players.append(player)

func remove_player(rid: RID) -> void:
	var pop_index = -1
	for i in range(players.size()):
		if players[i].get_rid() == rid:
			pop_index = i
			break
	players.pop_at(pop_index)
