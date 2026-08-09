extends CanvasLayer
class_name VersusScreenV2

signal fade
signal ended

@onready var teams_container: Control = $Control/TeamsContainer/Control
@onready var debug_left_team: TeamVersusCard = $Control/TeamsContainer/Control/TeamVersusCard
@onready var debug_right_team: TeamVersusCard = $Control/TeamsContainer/Control/TeamVersusCard2
@onready var versus_arena_card: VersusArenaCard = $Control/InfoContainer/Control/VersusArenaCard
@onready var team_versus_card_prefab: PackedScene = load("res://Prefabs/Menus/Versus/TeamVersusCard.tscn")

func _ready() -> void:
	if GameManager.current_level_config:
		versus_arena_card.arena = GameManager.current_arena
	if GameManager.get_team(0) and GameManager.get_team(0).players.size() > 0:
		debug_left_team.queue_free()
		instantiate_left_team_card()
	if GameManager.get_team(1) and GameManager.get_team(1).players.size() > 0:
		debug_right_team.queue_free()
		instantiate_right_team_card()

func instantiate_left_team_card() -> void:
	var left_team = GameManager.get_team(0).players.duplicate()
	left_team.reverse()
	var left_team_versus_card: TeamVersusCard = team_versus_card_prefab.instantiate()
	left_team_versus_card.team_position = PlayerVersusCard.PlayerVersusCardPosition.Left
	for player: Player in left_team:
		var character: Definitions.Characters = player.selected_character
		left_team_versus_card.characters.append(character)
		left_team_versus_card.characters_teams.append(Definitions.CharacterTeams[character])
	teams_container.add_child(left_team_versus_card)
	left_team_versus_card.set_anchors_and_offsets_preset(
		Control.PRESET_CENTER_LEFT,
		Control.PRESET_MODE_KEEP_SIZE
	)

func instantiate_right_team_card() -> void:
	var right_team = GameManager.get_team(1).players.duplicate()
	var right_team_versus_card: TeamVersusCard = team_versus_card_prefab.instantiate()
	right_team_versus_card.team_position = PlayerVersusCard.PlayerVersusCardPosition.Right
	for player: Player in right_team:
		var character: Definitions.Characters = player.selected_character
		right_team_versus_card.characters.append(character)
		right_team_versus_card.characters_teams.append(Definitions.CharacterTeams[character])
	teams_container.add_child(right_team_versus_card)
	right_team_versus_card.set_anchors_and_offsets_preset(
		Control.PRESET_CENTER_RIGHT,
		Control.PRESET_MODE_KEEP_SIZE
	)

func emit_fade_signal() -> void:
	fade.emit()

func emit_end_signal() -> void:
	ended.emit()
