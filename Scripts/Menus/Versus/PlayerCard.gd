extends Control
class_name PlayerCard

@export var player_name: String
@export var avatar: Texture2D
@export var team: Definitions.Teams
@export var team_icons: Array[Texture2D]

@onready var label: Label = $Control/PlayerName
@onready var team_decoration: TextureRect = $Control/TeamDecoration
@onready var avatar_rect: TextureRect = $Control/Avatar
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("RESET")
	label.text = player_name
	avatar_rect.texture = avatar
	team_decoration.texture = team_icons[team]

func play_announce() -> void:
	animation_player.play("Announce")

func play_quit() -> void:
	animation_player.play("Quit")
