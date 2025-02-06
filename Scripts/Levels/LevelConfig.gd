extends Node3D
class_name LevelConfig

@export_subgroup("Properties")
@export var level_name: String = ""
@export var spawn_points: Array[Node3D]
@export var randomize_spawn: bool = false

@export_subgroup("Environment")
@export var is_sunny: bool = false
@export var is_rainy: bool = false
@export var is_snowy: bool = false

@export_subgroup("Snapshot")
@export var snapshot_mode: bool = false
@export var snapshot_camera: Camera3D

var player_scene: PackedScene = load("res://Prefabs/Player1.tscn")
var spawn_indexes: Array

func _ready() -> void:
	GameManager.lock_cursor()
	GameManager.current_level_config = self
	if !GameManager.current_match and !snapshot_mode:
		generate_spawn_indexes()
		if snapshot_camera:
			snapshot_camera.queue_free()
		if !GameManager.get_player_one():
			create_player_one()
		GameManager.create_match(MatchManager.new())
	else:
		GameManager.unlock_cursor()

func generate_spawn_indexes() -> void:
	spawn_indexes = range(spawn_points.size())
	if randomize_spawn:
		spawn_indexes.shuffle()

func get_spawn_point(player_number: int) -> Node3D:
	return spawn_points[spawn_indexes[player_number]]

func create_player_one() -> void:
	var player_instance: Player = player_scene.instantiate()
	player_instance.player_type = Player.PlayerType.Player1
	player_instance.selected_character = Definitions.Characters.Kassey
	GameManager.add_player(player_instance)
