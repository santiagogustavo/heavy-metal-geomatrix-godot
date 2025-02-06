extends Node3D

signal selected

@export_file var redirect_to_scene: String

@export_subgroup("Definitions")
@export var avatar_cards: Array[AvatarCard]
@export var team_icons: Array[Texture2D]

@export_subgroup("References")
@export var character_name_label: Label
@export var team_icon: TextureRect
@export var team_name_label: Label
@export var stat_speed_label: Label
@export var stat_power_label: Label
@export var stat_vitality_label: Label

@export_subgroup("SFX")
@export var cursor_sfx: AudioStreamPlayer2D
@export var select_sfx: AudioStreamPlayer2D

@onready var character_container = $CharacterContainer

var current_card: AvatarCard
var current_select: CharacterController

var is_selected: bool = false
var focused_first: bool = false

func _ready() -> void:
	if !avatar_cards or !avatar_cards.size():
		return
	for avatar in avatar_cards:
		selected.connect(func (avatar_name: String):
			if avatar_name != avatar.name:
				avatar.focus_mode = Control.FOCUS_NONE
				avatar.disabled = true
		)
		avatar.focus_entered.connect(func ():
			if current_select:
				current_select.visible = false
				update_select_reset_skin()
			current_card = avatar
			update_select_character(avatar.select)
			cursor_sfx.play()
			update_character_name_label(avatar.select.character_name)
			update_team_icon(avatar.select.character_team)
			update_team_name_label(avatar.select.team_name)
			update_stat_speed_label(avatar.select.stat_speed)
			update_stat_power_label(avatar.select.stat_power)
			update_stat_vitality_label(avatar.select.stat_vitality)
		)
		avatar.button_down.connect(func ():
			if is_selected:
				return
			is_selected = true
			select_sfx.play()
			selected.emit(avatar.name)
			select_player(avatar)
		)
		character_container.add_child(avatar.select)
	focus_on_first()

func _process(_delta: float) -> void:
	set_process_input(!DebugMenuManager.is_menu_open)
	if DebugMenuManager.is_menu_open:
		focused_first = false
	elif !focused_first:
		focus_on_first()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_change_skin") and !is_selected:
		update_select_change_to_next_skin()

func select_player(avatar: AvatarCard) -> void:
	var instance: Player = load("res://Prefabs/Player1.tscn").instantiate()
	instance.selected_character = avatar.character
	instance.selected_skin = avatar.select.current_skin
	GameManager.add_player(instance)
	await avatar.select.animation_tree.animation_finished
	await get_tree().create_timer(0.5).timeout
	LoadingManager.next_scene = redirect_to_scene
	get_tree().change_scene_to_file(Definitions.Scenes.Loading)

func focus_on_first():
	focused_first = true
	if current_card:
		current_card.grab_focus()
	else:
		avatar_cards[0].grab_focus()

func update_select_character(character: CharacterController) -> void:
	current_select = character
	current_select.visible = true

func update_select_reset_skin() -> void:
	current_select.current_skin = 0

func update_select_change_to_next_skin() -> void:
	if current_select.current_skin == current_select.skins.size() - 1:
		current_select.current_skin = 0
	else:
		current_select.current_skin += 1

func update_character_name_label(character: String) -> void:
	character_name_label.text = character

func update_team_icon(team: Definitions.Teams) -> void:
	team_icon.texture = team_icons[team as int]

func update_team_name_label(team: String) -> void:
	team_name_label.text = team
	
func update_stat_speed_label(speed: int) -> void:
	stat_speed_label.text = "/".repeat(speed)

func update_stat_power_label(power: int) -> void:
	stat_power_label.text = "/".repeat(power)

func update_stat_vitality_label(vitality: int) -> void:
	stat_vitality_label.text = "/".repeat(vitality)
