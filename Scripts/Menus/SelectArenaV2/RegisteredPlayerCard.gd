extends Control
class_name RegisteredPlayerCard

@export_subgroup("Properties")
@export var player_type: Player.PlayerType
@export var mugshot_small: Texture2D

@onready var player_label: Label = $Outline/BG/Label
@onready var mugshot_rect: TextureRect = $Outline/BG/MugshotSmall

func _ready() -> void:
	match player_type:
		Player.PlayerType.Player1:
			player_label.text = "Player 1"
		Player.PlayerType.Player2:
			player_label.text = "Player 2"
		Player.PlayerType.Bot:
			player_label.text = "Cpu Bot"
	mugshot_rect.texture = mugshot_small
