extends Control
class_name MatchEndScreen

@onready var registered_player_card_prefab: PackedScene = load("res://Prefabs/Menus/SelectArena/RegisteredPlayerCard.tscn")
@onready var team_info_container: HBoxContainer = $MarginContainer/Control/MarginContainer/Control/TeamInfoContainer
@onready var example_registered_player: RegisteredPlayerCard = $MarginContainer/Control/MarginContainer/Control/TeamInfoContainer/RegisteredPlayerCard
@onready var winner_label: Label = $MarginContainer/Control/MarginContainer/Control/TeamInfoContainer/VBoxContainer/WinnerLabel
@onready var loser_label: Label = $MarginContainer/Control/MarginContainer/Control/TeamInfoContainer/VBoxContainer/LoserLabel
@onready var elapsed_time_value: Label = $MarginContainer/Control/MarginContainer/Control/Control/ElapsedTime/Value
@onready var total_time_value: Label = $MarginContainer/Control/MarginContainer/Control/Control/TotalTime/Value
@onready var taunt_win_player: AudioStreamPlayer2D = $TauntWin
@onready var taunt_lose_player: AudioStreamPlayer2D = $TauntLose

func _ready() -> void:
	var player_one_team: Array[Player] = GameManager.get_player_one_team()
	if !player_one_team.is_empty():
		example_registered_player.queue_free()
	for player in player_one_team:
		var registered_player_card: RegisteredPlayerCard = registered_player_card_prefab.instantiate()
		registered_player_card.player_type = player.player_type
		registered_player_card.mugshot_small = player.character.mugshot_small
		team_info_container.add_child(registered_player_card)
		team_info_container.move_child(registered_player_card, 0)
	if GameManager.get_winning_team() and GameManager.get_player_one():
		if GameManager.get_winning_team().name == GameManager.get_player_one().team.name:
			winner_label.visible = true
			loser_label.visible = false
			taunt_win_player.stream = GameManager.get_player_one().character.win_taunt
			taunt_win_player.play()
		else:
			winner_label.visible = false
			loser_label.visible = true
			taunt_lose_player.stream = GameManager.get_player_one().character.lose_taunt
			taunt_lose_player.play()
	var elapsed_time: float = GameManager.current_match.total_time if GameManager.current_match else 0.0
	var total_time: float = GameManager.current_match.total_time if GameManager.current_match else 0.0
	elapsed_time_value.text = format_time(elapsed_time)
	total_time_value.text = format_time(total_time)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		redirect_to_main_menu()

func format_time(total_seconds: float) -> String:
	var minutes: int = int(total_seconds / 60)
	var seconds: int = int(fmod(total_seconds, 60))
	var milliseconds: int = int(fmod(total_seconds, 1) * 1000)
	return "%02d:%02d.%03d" % [minutes, seconds, milliseconds]


func redirect_to_main_menu() -> void:
	var redirect_to_scene = "res://Scenes/MainMenu.tscn"
	SceneManager.load_scene_file(redirect_to_scene)
	queue_free()
