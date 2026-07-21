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
@export var spawn_bots_count: int = 1

@export_subgroup("Environment")
@export var is_sunny: bool = false
@export var is_rainy: bool = false
@export var is_snowy: bool = false

@export_subgroup("Snapshot")
@export var snapshot_mode: bool = false
@export var snapshot_viewport: SubViewport
@export var splash_animation_tree: AnimationTree
@export var splash_layer: CanvasLayer

@onready var versus_screen_resource: PackedScene = load("res://Prefabs/Menus/Versus/VersusScreen.tscn")
@onready var flyby_camera_resource: PackedScene = load("res://Prefabs/Levels/FlyByCamera.tscn")
var versus_screen_instance: VersusScreen

func _ready() -> void:
	GameManager.lock_cursor()
	GameManager.current_level_config = self
	if DebugCommands.flyby_mode:
		var flyby_camera: FlyByCamera = flyby_camera_resource.instantiate()
		if snapshot_viewport:
			var snapshot_camera: Camera3D = snapshot_viewport.get_child(0)
			if snapshot_camera:
				flyby_camera.start_position = snapshot_camera.global_position
				flyby_camera.start_rotation = snapshot_camera.global_rotation
			snapshot_viewport.queue_free()
		if splash_layer:
			splash_layer.queue_free()
		get_tree().root.add_child.call_deferred(flyby_camera)
	if !snapshot_mode and !DebugCommands.flyby_mode:
		if !GameManager.get_player_one():
			GameManager.create_player_one(Definitions.Characters.Lance)
			for i in range(spawn_bots_count):
				GameManager.create_bot()
		if !GameManager.current_match:
			GameManager.create_match(MatchManager.new())
			GameManager.current_match.time = 99
		GameManager.spawn_players()
		GameManager.added_player.connect(on_player_added)
		if play_versus_screen:
			instantiate_versus_screen()
		else:
			on_versus_screen_ended()
	elif !DebugCommands.flyby_mode:
		GameManager.unlock_cursor()

func _process(_delta: float) -> void:
	set_environment_composition_effects_intensity(VideoSettingsManager.motion_blur_intensity)

func after_process_first_frame() -> void:
	get_tree().root.add_child.call_deferred(versus_screen_instance)
	disable_environment_composition_effects()
	if snapshot_viewport:
		snapshot_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	get_tree().process_frame.disconnect(after_process_first_frame)

func instantiate_versus_screen() -> void:
	versus_screen_instance = versus_screen_resource.instantiate()
	versus_screen_instance.debug = false
	versus_screen_instance.level_splash = splash
	versus_screen_instance.fade.connect(func ():
		if snapshot_viewport:
			snapshot_viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	)
	versus_screen_instance.ended.connect(on_versus_screen_ended)
	get_tree().process_frame.connect(after_process_first_frame)

func enable_environment_composition_effects() -> void:
	if !world_environment or !world_environment.compositor:
		return
	for effect: CompositorEffect in world_environment.compositor.compositor_effects:
		effect.enabled = VideoSettingsManager.motion_blur_enabled

func disable_environment_composition_effects() -> void:
	if !world_environment or !world_environment.compositor:
		return
	for effect: CompositorEffect in world_environment.compositor.compositor_effects:
		effect.enabled = false

func set_environment_composition_effects_intensity(intensity: float) -> void:
	if !world_environment or !world_environment.compositor:
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
