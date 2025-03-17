extends Node

signal pause
signal resume
signal added_player
signal spawned_player

var current_level_config: LevelConfig
var current_scene_type: Definitions.SceneType = Definitions.SceneType.Intro

var engine_version: String = Engine.get_version_info().string

# Gameplay variables
var is_game_paused: bool = false
var current_match: MatchManager
var players: Array[Player] = []
var teams: Array[Team] = []

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func spawn_players() -> void:
	for team: Team in teams:
		for player: Player in team.players:
			team.spawn_player(player, current_level_config.get_available_spawn_point())

func reset_players_to_spawn_points():
	for team: Team in teams:
		for player: Player in team.players:
			player.heal_player(100)
			player.reset_player_to_spawn()
			player.character.reset_jiggle_bones()

func create_match(new_match: MatchManager) -> void:
	current_match = new_match
	new_match.round_start.connect(reset_players_to_spawn_points)
	new_match.round_end.connect(match_round_ended)
	get_tree().root.add_child.call_deferred(current_match)

func end_match() -> void:
	get_tree().root.remove_child.call_deferred(current_match)
	current_match.queue_free()
	current_match = null
	current_level_config = null

func create_team() -> int:
	var new_team = Team.new()
	new_team.name = "Team +" + str(teams.size())
	new_team.killed.connect(func (last_killed_player: Player): team_was_killed(last_killed_player))
	new_team.spawned_player.connect(func (player: Player): spawned_player.emit(player))
	add_child(new_team)
	teams.append(new_team)
	return teams.size() - 1

func get_team(index: int) -> Team:
	if index > teams.size() - 1:
		return null
	return teams[index]

func remove_team(index: int) -> void:
	teams[index].destroy()
	teams.pop_at(index)

func clear_teams():
	for team: Team in teams:
		team.destroy()
	teams = []

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
	if !current_match or current_match.round_status != MatchManager.RoundStatus.Started:
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
	for team: Team in teams:
		var index = team.players.map(func (player: Player): return player.player_type).find(Player.PlayerType.Player1)
		if index != -1:
			return team.players[index]
	return null

func get_enemies(team_name: String) -> Array[Player]:
	var enemies: Array[Player] = []
	for team: Team in teams:
		if team.name != team_name:
			for player: Player in team.players:
				enemies.append(player)
	return enemies

func add_player(player: Player, team: int) -> bool:
	if team >= teams.size():
		return false
	if current_level_config and !current_level_config.get_available_spawn_point():
		return false
	teams[team].add_player(player)
	added_player.emit(player, teams[team])
	return true

func team_was_killed(last_killed_player: Player) -> void:
	if current_match.can_end_round() and get_teams_alive().size() <= 1:
		current_match.end_round()
		if get_player_one():
			get_player_one().move_ko_pivot(last_killed_player.global_position, last_killed_player.global_rotation)

func get_teams_alive() -> Array[Team]:
	var teams_alive: Array[Team] = []
	for team: Team in teams:
		if team.is_team_alive():
			teams_alive.append(team)	
	return teams_alive

func get_healthiest_team() -> Team:
	var healthiest_team: Team = teams[0]
	for team: Team in teams:
		if team.get_team_health() > healthiest_team.get_team_health():
			healthiest_team = team
	return healthiest_team

func get_lowest_team() -> Team:
	var lowest_team: Team = teams[0]
	for team: Team in teams:
		if team.get_team_health() < lowest_team.get_team_health():
			lowest_team = team
	return lowest_team

func match_round_ended() -> void:
	var player_one: Player = get_player_one()
	player_one.move_ko_pivot(player_one.global_position, player_one.global_rotation)

func is_player_one_win() -> bool:
	return get_healthiest_team().name == get_player_one().team.name

func is_player_one_lose() -> bool:
	return (
		get_player_one().team.is_team_dead()
		or get_lowest_team().name == get_player_one().team.name
	)

func is_player_one_win_excessive() -> bool:
	return (
		get_healthiest_team().name == get_player_one().team.name
		and get_player_one().team.is_team_full_health()
	)

func is_match_a_draw() -> bool:
	var teams_alive: Array[Team] = get_teams_alive()
	if teams_alive.size() != teams.size():
		return false
	var teams_health: int = teams[0].get_team_health()
	for team: Team in teams_alive:
		if team.get_team_health() != teams_health:
			return false
	return true
