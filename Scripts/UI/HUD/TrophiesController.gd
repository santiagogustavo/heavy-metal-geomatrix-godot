extends HBoxContainer

@export var team: int
@onready var trophy: PackedScene = load("res://Prefabs/UI/Trophy.tscn")

var trophies: Array[Trophy] = []

func _ready() -> void:
	if team >= GameManager.teams.size():
		queue_free()
		return
	var trophies_to_instantiate = GameManager.current_match.rounds
	for i in range(trophies_to_instantiate):
		var new_trophy: Trophy = trophy.instantiate()
		trophies.append(new_trophy)
		add_child(new_trophy)

func _process(_delta: float) -> void:
	var index = 0
	for result in GameManager.teams[team].round_results:
		trophies[index].is_excessive = result == MatchManager.RoundResult.Excessive
		trophies[index].is_win = result == MatchManager.RoundResult.Win
		index += 1
