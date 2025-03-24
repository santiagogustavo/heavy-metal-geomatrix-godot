extends CanvasLayer
class_name VersusScreen

signal fade
signal ended

@export var debug: bool = true

@export var player_card_left: PackedScene
@export var player_card_right: PackedScene

@export var max_container_scale: float = 0.8
@export var min_container_scale: float = 0.4

@export var level_splash: Texture2D

@onready var splash_rect: LevelSplashGradient = $Control/LevelSplash
@onready var container_scale_factor: float = max_container_scale - min_container_scale

@onready var players_left: Array = (
	GameManager.teams[0].players
	if GameManager.teams.size() == 2
	else []
)
@onready var players_right: Array = (
	GameManager.teams[1].players
	if GameManager.teams.size() == 2
	else []
)

@onready var team_left_container: VBoxContainer = $Control/TeamLeft
@onready var team_right_container: VBoxContainer = $Control/TeamRight

@onready var splash_debug: LevelSplashGradient = $Control/LevelSplashDebug
@onready var team_left_container_debug: VBoxContainer = $Control/TeamLeftDebug
@onready var team_right_container_debug: VBoxContainer = $Control/TeamRightDebug

func _ready() -> void:
	if !debug:
		splash_debug.queue_free()
		team_left_container_debug.queue_free()
		team_right_container_debug.queue_free()
	var has_players_on_team_left: bool = players_left.size() > 0
	var has_players_on_team_right: bool = players_right.size() > 0
	if !has_players_on_team_left and !has_players_on_team_right:
		emit_end_signal()
		return
	if level_splash:
		splash_rect.update_material_gradient(level_splash)
	for player: Player in players_left:
		if player.character:
			var instance: PlayerCard = create_character_instance(player, player_card_left)
			team_left_container.add_child(instance)
	for player: Player in players_right:
		if player.character:
			var instance: PlayerCard = create_character_instance(player, player_card_right)
			team_right_container.add_child(instance)
	var left_container_scale_factor: float = (
		max_container_scale
		- (container_scale_factor * ((players_left.size() - 1) / 2.0))
	)
	var right_container_scale_factor: float = (
		max_container_scale
		- (container_scale_factor * ((players_right.size() - 1) / 2.0))
	)
	team_left_container.scale = Vector2(left_container_scale_factor, left_container_scale_factor)
	team_right_container.scale = Vector2(right_container_scale_factor, right_container_scale_factor)

func create_character_instance(player: Player, card: PackedScene) -> PlayerCard:
	var instance: PlayerCard = card.instantiate()
	instance.player_name = player.player_name
	instance.team = player.character.character_team
	instance.avatar = player.character.avatar_big
	return instance

func emit_fade_signal() -> void:
	fade.emit()

func emit_end_signal() -> void:
	ended.emit()
