class_name DebugCommands

signal clear_console

var autocomplete_methods: Array = []

var foo: String = 'Hello!'

var is_stats_overlay_open: bool = false 

static var target_point_visible: bool = false
static var full_ammo: bool = false
static var full_health: bool = false
static var is_pacifist: bool = false

var tree: SceneTree

func _init(root_tree: SceneTree) -> void:
	tree = root_tree

func _get_autocomplete_info() -> void:
	autocomplete_methods = get_script().get_script_method_list().map(func (x: Dictionary) -> String: return x.name)
	autocomplete_methods = autocomplete_methods.filter(func (x: String) -> bool: return not x.begins_with("_"))

func _get_autocomplete_match(input: String) -> String:
	for method: String in autocomplete_methods:
		if method.begins_with(input):
			return method
	return input

func hello(text: String = foo) -> String:
	return text

func clear() -> void:
	clear_console.emit()

func reload() -> void:
	tree.reload_current_scene()

func pacifist() -> void:
	is_pacifist = !is_pacifist

func add_bot() -> String:
	var resource: Resource = load("res://Prefabs/BotPlayer.tscn")
	resource.resource_local_to_scene = true
	var instance: Player = resource.instantiate()
	instance.selected_character = [
		#Definitions.Characters.Mayfly,
		Definitions.Characters.Slash,
		#Definitions.Characters.Di,
		#Definitions.Characters.Kassey
	].pick_random()
	instance.selected_skin = randi_range(0, 3)
	if !GameManager.get_team(1):
		GameManager.create_team()
	return "Bot added!" if GameManager.add_player(instance, 1) else "No spawns available :("

func change_player_skin(skin: int) -> String:
	if GameManager.get_player_one():
		var player = GameManager.get_player_one()
		player.selected_skin = clamp(skin, 0, player.character.skins.size() - 1)
		return "Changed " + player.player_name + " skin!"
	else:
		return "No player available"

func heal_player(amount: int = 15, team_index: int = -1, player_index: int = -1) -> String:
	var player: Player
	if player_index > -1:
		player = GameManager.get_team(team_index).players[player_index]
	else:
		player = GameManager.get_player_one() 
	if player:
		player.heal_player(amount)
		return "Healed " + player.player_name + " by " + str(amount) + " points"
	else:
		return "No player available"

func damage_player(amount: int = 15, team_index: int = -1, player_index: int = -1) -> String:
	var player: Player
	if player_index > -1:
		player = GameManager.get_team(team_index).players[player_index]
	else:
		player = GameManager.get_player_one() 
	if player:
		player.damage_player(amount)
		return "Damaged " + player.player_name + " by " + str(amount) + " points"
	else:
		return "No player available"

func relive_player(team_index: int = -1, player_index: int = -1) -> String:
	var player: Player
	if player_index > -1:
		player = GameManager.get_team(team_index).players[player_index]
	else:
		player = GameManager.get_player_one() 
	if player:
		player.heal_player(100)
		return "Relived " + player.player_name
	else:
		return "No player available"

func kill_player(team_index: int = -1, player_index: int = -1) -> String:
	var player: Player
	if player_index > -1:
		player = GameManager.get_team(team_index).players[player_index]
	else:
		player = GameManager.get_player_one() 
	if player:
		player.damage_player(100)
		return "Killed " + player.player_name
	else:
		return "No player available"

func show_stats() -> void:
	is_stats_overlay_open = !is_stats_overlay_open

func show_target_point() -> void:
	target_point_visible = !target_point_visible

func idkfa() -> void:
	full_ammo = !full_ammo

func iddqd() -> void:
	full_health = !full_health

func start_round() -> String:
	if GameManager.current_match:
		var success = GameManager.current_match.start_round()
		if success:
			return "Round " + str(GameManager.current_match.current_round) + " started!"
		else:
			return "Round " + str(GameManager.current_match.current_round) + " already ongoing or final round"
	else:
		return "No matches available"

func end_round() -> String:
	if GameManager.current_match:
		var success = GameManager.current_match.end_round()
		if success:
			return "Round " + str(GameManager.current_match.current_round) + " ended!"
		else:
			return "Round " + str(GameManager.current_match.current_round) + " already ended or not started"
	else:
		return "No matches available"

func timeout_round() -> String:
	if GameManager.current_match:
		GameManager.current_match.timer.stop()
		GameManager.current_match.timer.start(0.1)
		return "Round " + str(GameManager.current_match.current_round) + " timeouted!"
	else:
		return "No matches available"
