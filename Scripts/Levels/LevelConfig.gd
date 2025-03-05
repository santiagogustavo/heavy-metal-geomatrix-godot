extends Node3D
class_name LevelConfig

@export_subgroup("Properties")
@export var level_name: String = ""
@export var splash: Texture2D
@export var spawn_points: Array[SpawnPoint]
@export var randomize_spawn: bool = false

@export_subgroup("Environment")
@export var is_sunny: bool = false
@export var is_rainy: bool = false
@export var is_snowy: bool = false

@export_subgroup("Snapshot")
@export var snapshot_mode: bool = false
@export var snapshot_camera: Camera3D
@export var splash_animation_tree: AnimationTree

func _ready() -> void:
	GameManager.lock_cursor()
	GameManager.current_level_config = self
	if !snapshot_mode:
		if !GameManager.get_player_one():
			create_player_one()
		if !GameManager.current_match:
			GameManager.create_match(MatchManager.new())
		if snapshot_camera:
			if splash_animation_tree:
				await get_tree().create_timer(2.0).timeout
				splash_animation_tree.set("parameters/conditions/fade_out", true)
			snapshot_camera.queue_free()
		GameManager.spawn_players()
		GameManager.added_player.connect(on_player_added)
		await get_tree().create_timer(0.1).timeout
		GameManager.current_match.start_round()
	else:
		GameManager.unlock_cursor()

func _exit_tree() -> void:
	GameManager.clear_teams()

func get_available_spawn_point() -> SpawnPoint:
	var spawn_point: SpawnPoint = null
	for spawn: SpawnPoint in spawn_points:
		if !spawn.occupied:
			spawn_point = spawn
			break
	return spawn_point

func on_player_added(player: Player, team: Team) -> void:
	if get_available_spawn_point():
		team.spawn_player(player, get_available_spawn_point())

func create_player_one() -> void:
	var player_instance: Player = load("res://Prefabs/Player1.tscn").instantiate()
	player_instance.player_type = Player.PlayerType.Player1
	player_instance.selected_character = Definitions.Characters.Slash
	var team_index: int = GameManager.create_team()
	GameManager.add_player(player_instance, team_index)
