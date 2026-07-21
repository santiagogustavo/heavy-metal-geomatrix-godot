extends Node3D
class_name SelectPlayerMenuV2

@onready var player_card_prefab: PlayerCardV2 = (
	load("res://Prefabs/Menus/SelectPlayer/PlayerCard.tscn") as PackedScene
).instantiate()
@onready var grid_container_example: GridContainer = $Control/GridContainerExample
@onready var player_cards_container: GridContainer = $Control/PlayerCardsContainer
@onready var player_info_card: PlayerInfoCard = $Control/PlayerInfoCard
@onready var status_label: LabelRandomizerEffect = $Control/MarginContainer/Control/Status
@onready var team_card: TeamCard = $Control/TeamCard
@onready var select_taunt: AudioStreamPlayer2D = $Control/PlayerInfoCard/SelectTaunt

var player_cards: Array[PlayerCardV2] = []

var focused_first: bool = false

var redirect_to_scene: NodePath

func _ready() -> void:
	redirect_to_scene = "res://Scenes/SelectArenaV2.tscn"
	grid_container_example.queue_free()
	instantiate_player_cards()

func _process(_delta: float) -> void:
	set_process_input(!DebugMenuManager.is_menu_open)
	if DebugMenuManager.is_menu_open:
		focused_first = false
	elif !focused_first:
		focus_on_first()

func instantiate_player_cards() -> void:
	for character in Definitions.Characters:
		var character_key: int = Definitions.Characters[character]
		var current_character_player_card: PlayerCardV2 = player_card_prefab.duplicate()
		var current_character: CharacterController = (
			load(Definitions.Players[character_key]) as PackedScene
		).instantiate()
		current_character_player_card.character_portrait = current_character.portrait_small
		current_character_player_card.selected.connect(func (): 
			handle_selected_player_character(character_key, current_character.current_skin)
		)
		current_character_player_card.focus_entered.connect(func ():
			player_info_card.character_name = Definitions.CharacterNames[character_key]
			player_info_card.character_team = current_character.character_team
			player_info_card.character_bio = current_character.bio
			player_info_card.stat_speed = current_character.stat_speed
			player_info_card.stat_power = current_character.stat_power
			player_info_card.stat_vitality = current_character.stat_vitality
			player_info_card.select_taunt = current_character.select_taunt
			update_loadout_label(current_character.initial_loadout)
			team_card.team = current_character.character_team
			team_card.position.y = (
				current_character_player_card.get_screen_position().y - 2
			)
			current_character.current_skin = 0
			player_info_card.portrait_texture = current_character.portrait_skins[0]
			player_info_card.handle_change_player()
		)
		current_character_player_card.change_skin.connect(func ():
			handle_character_next_skin(current_character)
		)
		player_cards_container.add_child(current_character_player_card)
		player_cards.append(current_character_player_card)
	
func focus_on_first() -> void:
	player_cards[0].grab_focus()
	focused_first = true

func handle_selected_player_character(character: Definitions.Characters, skin: int) -> void:
	for card in player_cards:
		card.focus_mode = Control.FOCUS_NONE
		card.disabled = true
	player_info_card.handle_selected()
	status_label.text = "player1 selected! ^-^"
	status_label.play_effect()
	GameManager.create_player_one(character, skin)
	GameManager.create_bot()
	SceneManager.persist_node(select_taunt)
	get_tree().create_timer(1.0).timeout.connect(func ():
		SceneManager.load_scene_file(redirect_to_scene)
	)

func handle_character_next_skin(character: CharacterController) -> void:
	if character.current_skin < character.skins.size() - 1:
		character.current_skin += 1
	else:
		character.current_skin = 0
	player_info_card.portrait_texture = character.portrait_skins[character.current_skin]
	player_info_card.handle_change_skin()

func update_loadout_label(loadout: PackedScene) -> void:
	if !loadout:
		player_info_card.loadout = ""
		return
	var instance = loadout.instantiate()
	if "item_name" in instance:
		player_info_card.loadout = instance.item_name
