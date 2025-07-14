extends Node3D
class_name LevelConfig

@export_subgroup("Properties")
@export var level_name: String = ""
@export var splash: Texture2D
@export var spawn_points: Array[SpawnPoint]
@export var randomize_spawn: bool = false
@export var pickup_spawner: Spawner
@export var ost_player: AudioStreamPlayer2D
@export var world_environment: WorldEnvironment
@export var play_versus_screen: bool = true

@export_subgroup("Environment")
@export var is_sunny: bool = false
@export var is_rainy: bool = false
@export var is_snowy: bool = false

@export_subgroup("Snapshot")
@export var snapshot_mode: bool = false
@export var snapshot_viewport: SubViewport
@export var splash_animation_tree: AnimationTree

@onready var versus_screen_resource: PackedScene = load("res://Prefabs/Menus/Versus/VersusScreen.tscn")
var versus_screen_instance: VersusScreen
var frames_to_preprocess_splash: int = 1

func _ready() -> void:
	GameManager.lock_cursor()
	GameManager.current_level_config = self
	if !snapshot_mode:
		if !GameManager.get_player_one():
			create_player_one()
			create_bot()
		if !GameManager.current_match:
			GameManager.create_match(MatchManager.new())
		GameManager.spawn_players()
		GameManager.added_player.connect(on_player_added)
		if play_versus_screen:
			instantiate_versus_screen()
		else:
			on_versus_screen_ended()
	else:
		GameManager.unlock_cursor()

func _process(_delta: float) -> void:
	set_environment_composition_effects_intensity(VideoSettingsManager.motion_blur_intensity)

func instantiate_versus_screen() -> void:
	versus_screen_instance = versus_screen_resource.instantiate()
	versus_screen_instance.debug = false
	versus_screen_instance.level_splash = splash
	versus_screen_instance.fade.connect(func ():
		if snapshot_viewport:
			snapshot_viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	)
	versus_screen_instance.ended.connect(on_versus_screen_ended)
	get_tree().root.add_child.call_deferred(versus_screen_instance)
	disable_environment_composition_effects()
	for i in range(frames_to_preprocess_splash):
		await get_tree().process_frame
	if snapshot_viewport:
		snapshot_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func enable_environment_composition_effects() -> void:
	if !world_environment:
		return
	for effect: CompositorEffect in world_environment.compositor.compositor_effects:
		effect.enabled = VideoSettingsManager.motion_blur_enabled

func disable_environment_composition_effects() -> void:
	if !world_environment:
		return
	for effect: CompositorEffect in world_environment.compositor.compositor_effects:
		effect.enabled = false

func set_environment_composition_effects_intensity(intensity: float) -> void:
	if !world_environment:
		return
	for effect: CompositorEffect in world_environment.compositor.compositor_effects:
		effect.intensity = intensity

func on_versus_screen_ended() -> void:
	enable_environment_composition_effects()
	await play_splash_sequence()
	start_match()

func play_splash_sequence() -> void:
	if ost_player:
		ost_player.play()
	if !snapshot_viewport:
		return
	if splash_animation_tree:
		await get_tree().create_timer(2.0).timeout
		splash_animation_tree.set("parameters/conditions/fade_out", true)
	snapshot_viewport.queue_free()

func start_match() -> void:
	await get_tree().create_timer(0.1).timeout
	if versus_screen_instance:
		versus_screen_instance.queue_free()
	GameManager.current_match.start_round()

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

func create_bot() -> void:
	var debug: DebugCommands = DebugCommands.new(get_tree())
	debug.add_bot()
