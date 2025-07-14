extends Control

@onready var container: HFlowContainer = $HFlowContainer
@onready var versus_card: PackedScene = load("res://Prefabs/UI/VersusCard.tscn")

func _ready() -> void:
	GameManager.spawned_player.connect(func (player: Player):
		add_versus_card(player)
	)
	for team: Team in GameManager.teams:
		for player: Player in team.players:
			add_versus_card(player)

func add_versus_card(player: Player) -> void:
	if player.player_type == Player.PlayerType.Player1:
		return
	var instance: VersusCard = versus_card.instantiate()
	instance.player_name = player.player_name
	instance.avatar = player.character.avatar_big
	instance.player = player
	container.add_child(instance)
