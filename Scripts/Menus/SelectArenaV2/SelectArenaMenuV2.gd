extends Node3D
class_name SelectArenaMenuV2

@onready var arena_card_prefab: ArenaCardV2 = (
	load("res://Prefabs/Menus/SelectArena/ArenaCardV2.tscn") as PackedScene
).instantiate()
@onready var player_card_prefab: RegisteredPlayerCard = (
	load("res://Prefabs/Menus/SelectArena/RegisteredPlayerCard.tscn") as PackedScene
).instantiate()
@onready var player1_prefab: Player = (
	load("res://Prefabs/Player1.tscn") as PackedScene
).instantiate()
@onready var bot_player_prefab: Player = (
	load("res://Prefabs/BotPlayer.tscn") as PackedScene
).instantiate()

@onready var card_container: Container = $Control/CardContainer
@onready var arena_cards_container: Container = $Control/ArenaCardContainer
@onready var player_cards_container: Container = $Control/MarginContainer/Control/RegisteredPlayersContainer/HBoxContainer
@onready var splash_bg: TextureRect = $Control/BG
@onready var status_label: LabelRandomizerEffect = $Control/MarginContainer/Control/Status
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_tree_state: AnimationNodeStateMachinePlayback = (
	animation_tree.get("parameters/playback")
)
@onready var placeholder_player_card: RegisteredPlayerCard = $Control/MarginContainer/Control/RegisteredPlayersContainer/HBoxContainer/Placeholder

var arena_cards: Array[ArenaCardV2] = []

var focused_first: bool = false

var rules_rounds: int = 2
var rules_time: int = 60

func _ready() -> void:
	card_container.queue_free()
	placeholder_player_card.queue_free()
	instantiate_arena_cards()
	instantiate_player_cards()

func _process(_delta: float) -> void:
	set_process_input(!DebugMenuManager.is_menu_open)
	if DebugMenuManager.is_menu_open:
		focused_first = false
	elif !focused_first:
		focus_on_first()

func instantiate_arena_cards() -> void:
	var max_index: int = Definitions.Arenas.size() - 1
	for arena in Definitions.Arenas:
		var arena_key: int = Definitions.Arenas[arena]
		var arena_z_index: int = max_index - arena_key
		var current_arena_card: ArenaCardV2 = arena_card_prefab.duplicate()
		var current_arena: ArenaController = (
			load(Definitions.ArenaScenes[arena_key]) as PackedScene
		).instantiate()
		current_arena_card.arena_name = Definitions.ArenaNames[arena_key]
		current_arena_card.arena_splash = current_arena.splash_small
		current_arena_card.focus_entered.connect(func ():
			animation_tree_state.travel("ChangeArena", true)
			splash_bg.texture = current_arena.splash_big
			show_cards_from_index(arena_key)
			update_current_card_focus(arena_key)
		)
		current_arena_card.selected.connect(func (): 
			handle_selected_arena(arena_key)
		)
		current_arena_card.z_index = arena_z_index
		arena_cards_container.add_child(current_arena_card)
		arena_cards.append(current_arena_card)

func instantiate_player_cards() -> void:
	if !GameManager.get_players().size():
		GameManager.create_player_one()
		GameManager.create_bot()
	for player in GameManager.get_players():
		var player_card_instance: RegisteredPlayerCard = player_card_prefab.duplicate()
		var character_key: Definitions.Characters = player.selected_character
		var current_character: CharacterController = (
			load(Definitions.Players[character_key]) as PackedScene
		).instantiate()
		player_card_instance.player_type = player.player_type
		player_card_instance.mugshot_small = current_character.mugshot_small
		player_cards_container.add_child(player_card_instance)

func focus_on_first() -> void:
	arena_cards[0].grab_focus()
	focused_first = true

func handle_selected_arena(arena: Definitions.Arenas) -> void:
	for card in arena_cards:
		card.focus_mode = Control.FOCUS_NONE
		card.disabled = true
	status_label.text = "arena selected! get ready to fight!"
	status_label.typing_time = 0.5
	status_label.play_effect()
	GameManager.create_match(MatchManager.new())
	GameManager.current_match.rounds = rules_rounds
	GameManager.current_match.time = rules_time
	get_tree().create_timer(1.0).timeout.connect(func (): 
		SceneManager.load_scene_file(Definitions.ArenaScenes[arena])
	)

func show_cards_from_index(index: int) -> void:
	var current_card_z_index = arena_cards.size()
	arena_cards[index].z_index = current_card_z_index
	arena_cards[index].scale = Vector2(1.0, 1.0)
	var left_index: int = index - 1
	var right_index: int = index + 1
	while left_index >= 0:
		arena_cards[left_index].scale = Vector2(0.9, 0.9)
		arena_cards[left_index].z_index = current_card_z_index - (index - left_index)
		left_index -= 1
	while right_index <= arena_cards.size() - 1:
		arena_cards[right_index].scale = Vector2(0.9, 0.9)
		arena_cards[right_index].z_index = current_card_z_index - (right_index - index)
		right_index += 1

func update_current_card_focus(index: int) -> void:
	var left_index: int = index - 1 if index > 0 else arena_cards.size() - 1
	var right_index: int = index + 1 if index < arena_cards.size() - 1 else 0
	arena_cards[index].focus_neighbor_left = arena_cards[left_index].get_path()
	arena_cards[index].focus_neighbor_right = arena_cards[right_index].get_path()
