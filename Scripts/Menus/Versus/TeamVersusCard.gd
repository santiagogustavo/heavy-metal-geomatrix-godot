extends Control
class_name TeamVersusCard

@export var team_position: PlayerVersusCard.PlayerVersusCardPosition
@export var characters: Array[Definitions.Characters]
@export var characters_teams: Array[Definitions.Teams]

@onready var player_versus_card_prefab: PackedScene = load(
	"res://Prefabs/Menus/Versus/PlayerVersusCard.tscn"
)
@onready var character_name_label_prefab: PackedScene = load(
	"res://Prefabs/Menus/Versus/CharacterNameLabel.tscn"
)
@onready var debug_container: HBoxContainer = $DebugContainer
@onready var debug_names_container: HBoxContainer = $DebugNamesContainer
@onready var player_versus_cards_container: HBoxContainer = $PlayerVersusCards
@onready var player_name_cards_container: HBoxContainer = $PlayerNameCards

func _ready() -> void:
	debug_container.queue_free()
	debug_names_container.queue_free()
	if team_position == PlayerVersusCard.PlayerVersusCardPosition.Left:
		player_versus_cards_container.alignment = BoxContainer.ALIGNMENT_END
	else:
		player_versus_cards_container.alignment = BoxContainer.ALIGNMENT_BEGIN
	var current_index: int = 0
	for character in characters:
		var player_versus_card: PlayerVersusCard = player_versus_card_prefab.instantiate()
		var character_name_label: CharacterNameLabel = character_name_label_prefab.instantiate()
		var index_factor: int = characters.size() - current_index - 1
		character_name_label.character = character
		player_name_cards_container.add_child(character_name_label)
		player_versus_card.card_position = team_position
		player_versus_card.character = character
		player_versus_card.character_team = characters_teams[current_index]
		player_versus_cards_container.add_child(player_versus_card)
		var modulate_factor = 1.0 - index_factor * 0.1
		player_versus_card.mugshot.self_modulate = Color(1.0, 1.0, 1.0, modulate_factor)
		if team_position == PlayerVersusCard.PlayerVersusCardPosition.Left:
			var scale_factor: float = 1.0 - (index_factor * 0.1)
			player_versus_card.pivot.scale = Vector2(scale_factor, scale_factor)
			player_versus_card.pivot.position.y -= index_factor * 25
			character_name_label.name_label.position.y -= index_factor * 25
			character_name_label.name_label.scale = Vector2(scale_factor, scale_factor)
			player_versus_card.z_index = current_index
		else:
			var scale_factor: float = 1.0 - current_index * 0.1
			player_versus_card.pivot.scale = Vector2(scale_factor, scale_factor)
			player_versus_card.pivot.position.y -= current_index * 25
			character_name_label.name_label.position.y -= current_index * 25
			character_name_label.name_label.scale = Vector2(scale_factor, scale_factor)
			player_versus_card.z_index = index_factor
		current_index += 1
