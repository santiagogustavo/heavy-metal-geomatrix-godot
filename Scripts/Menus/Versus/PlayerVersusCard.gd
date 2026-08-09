extends Control
class_name PlayerVersusCard

enum PlayerVersusCardPosition {
	Left,
	Right,
}

@export var card_position: PlayerVersusCardPosition
@export var character: Definitions.Characters
@export var character_team: Definitions.Teams
@export var custom_scale: Vector2

@onready var pivot: Control = $Pivot
@onready var mugshot: MugshotViewport = $Pivot/Portrait
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var character_name: CharacterNameLabel = $Pivot/Portrait/CharacterName
@onready var team_icon: TeamIcon = $Pivot/Portrait/TeamIcon

func _ready() -> void:
	if custom_scale:
		scale = custom_scale
	mugshot.character = character
	character_name.character = character
	team_icon.team = character_team
	animation_tree.set(
		"parameters/conditions/is_left",
		card_position == PlayerVersusCardPosition.Left
	)
	animation_tree.set(
		"parameters/conditions/is_right",
		card_position == PlayerVersusCardPosition.Right
	)
