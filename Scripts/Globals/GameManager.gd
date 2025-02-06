extends Node

signal pause
signal resume

var current_level_config: LevelConfig
var current_scene_type: Definitions.SceneType = Definitions.SceneType.Intro

var engine_version: String = Engine.get_version_info().string

# Gameplay variables
var is_game_paused: bool = false
var current_match: MatchManager
static var players: Array[Player] = []
var occupied_spawns: Array[int] = []

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func spawn_player(player: Player, index: int) -> bool:
	var spawn_point = current_level_config.get_spawn_point(index)
	player.position = spawn_point.global_position
	player.rotation = spawn_point.global_rotation
	get_tree().root.add_child.call_deferred(player)
	return true

func spawn_players() -> void:
	var index: int = 0
	for player: Player in players:
		spawn_player(player, index)
		index = index + 1

func reset_players_to_spawn_points():
	for player: Player in players:
		player.character.jiggle_physics_enabled = false
		player.reset_player_to_spawn()
		get_tree().create_timer(0.5).timeout.connect(func (): player.character.jiggle_physics_enabled = true)

func create_match(new_match: MatchManager) -> void:
	current_match = new_match
	spawn_players()
	new_match.round_start.connect(reset_players_to_spawn_points)
	get_tree().root.add_child.call_deferred(current_match)

func end_match() -> void:
	clear_players()
	get_tree().root.remove_child.call_deferred(current_match)
	current_match.queue_free()
	current_match = null

func clear_players():
	occupied_spawns = []
	for player: Player in players:
		players.erase(player)
		player.queue_free()

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
	var index = players.map(func (player: Player): return player.player_type).find(Player.PlayerType.Player1)
	return players[index] if index != -1 else null

func add_player(player: Player) -> bool:
	if !current_level_config:
		players.append(player)
		return true
	if players.size() == current_level_config.spawn_points.size():
		return false
	players.append(player)
	if current_match:
		spawn_player(player, players.size() - 1)
	return true

func remove_player(rid: RID) -> void:
	var pop_index = -1
	for i in range(players.size()):
		if players[i].get_rid() == rid:
			pop_index = i
			break
	players.pop_at(pop_index)
