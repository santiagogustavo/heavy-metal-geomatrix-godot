extends Control
class_name CharacterNameLabel

@export var character: Definitions.Characters
@export var player_type: Definitions.PlayerType

@onready var name_label: Label = $Label
@onready var player_tag: Label = $Label/PlayerTag

func _process(_delta: float) -> void:
	name_label.text = Definitions.CharacterNames[character]
	if player_type == Definitions.PlayerType.Player1:
		player_tag.text = "Player 1"
	elif player_type == Definitions.PlayerType.Player2:
		player_tag.text = "Player 2"
	else:
		player_tag.text = "CPU Bot"
