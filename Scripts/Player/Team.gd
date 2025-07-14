extends Node
class_name Team

signal added_player
signal spawned_player
signal removed_player
signal killed

@export_subgroup("Properties")
@export var team_name: String
@export var players: Array[Player]
@export var score: int
@export var round_results: Array[MatchManager.RoundResult]

func destroy() -> void:
	clear_players()
	queue_free()

func get_player(rid: RID) -> Player:
	var index = players.map(func (player: Player): return player.get_rid()).find(rid)
	return players[index] if index != -1 else null

func spawn_player(player: Player, spawn_point: SpawnPoint) -> void:
	spawn_point.occupied = true
	player.spawn_point = spawn_point
	get_tree().root.add_child.call_deferred(player)
	await player.player_ready
	spawned_player.emit(player)
	player.player_killed.connect(func (): on_player_killed(player))

func add_player(player: Player) -> void:
	player.team = self
	players.append(player)
	added_player.emit(player.get_rid())

func remove_player(rid: RID) -> void:
	var pop_index = players.map(func (player: Player): return player.get_rid()).find(rid)
	if pop_index != -1:
		players[pop_index].spawn_point.occupied = false
		players[pop_index].queue_free()
		players.pop_at(pop_index)
		removed_player.emit(rid)

func clear_players() -> void:
	for player: Player in players:
		remove_player(player.get_rid())
		await removed_player

func get_players_alive() -> Array[Player]:
	var alive: Array[Player] = []
	for player: Player in players:
		if player.health > 0:
			alive.append(player)
	return alive

func get_team_health() -> int:
	var team_health: int = 0
	for player: Player in players:
		team_health += player.health
	return roundi(float(team_health) / float(players.size()))

func is_health_equal_for_players() -> bool:
	var current_health: int = players[0].health
	var health_equal: bool = true
	for player: Player in players:
		if player.health != current_health:
			health_equal = false
	return health_equal

func is_team_alive() -> bool:
	return get_players_alive().size() > 0

func is_all_team_alive() -> bool:
	return get_players_alive().size() == players.size()

func is_team_dead() -> bool:
	return get_players_alive().size() == 0

func is_team_full_health() -> bool:
	return is_health_equal_for_players() and players[0].health == 100

func on_player_killed(last_killed_player: Player) -> void:
	if is_team_dead():
		killed.emit(last_killed_player)
