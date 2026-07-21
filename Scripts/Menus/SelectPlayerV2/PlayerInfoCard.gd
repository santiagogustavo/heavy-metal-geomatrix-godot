extends Control
class_name PlayerInfoCard

@export_subgroup("Properties")
@export var character_name: String
@export var character_team: Definitions.Teams
@export var character_bio: String
@export var stat_speed: int
@export var stat_power: int
@export var stat_vitality: int
@export var loadout: String
@export var portrait_texture: Texture2D
@export var select_taunt: AudioStream

@onready var label_name: Label = $InfoContainer/VBoxContainer/LabelName
@onready var label_team: Label = $InfoContainer/VBoxContainer/LabelTeam
@onready var label_bio: RichTextLabel = $InfoContainer/VBoxContainer/LabelBio
@onready var label_speed: Label = $InfoContainer/GridContainer/ValueSpeed
@onready var label_power: Label = $InfoContainer/GridContainer/ValuePower
@onready var label_vitality: Label = $InfoContainer/GridContainer/ValueVitality
@onready var label_loadout: Label = $InfoContainer/GridContainer/ValueLoadout
@onready var portrait: TextureRect = $PortraitContainer/Portrait
@onready var team_icon: TeamIcon = $Control/TeamIcon
@onready var select_taunt_stream_player: AudioStreamPlayer2D = $SelectTaunt
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_tree_playback: AnimationNodeStateMachinePlayback = (
	animation_tree.get("parameters/playback")
)

func _ready() -> void:
	handle_change_player()

func update_character_values() -> void:
	label_name.text = character_name
	label_team.text = Definitions.TeamNames[character_team]
	label_bio.text = character_bio
	label_speed.text = "/".repeat(stat_speed)
	label_power.text = "/".repeat(stat_power)
	label_vitality.text = "/".repeat(stat_vitality)
	portrait.texture = portrait_texture
	team_icon.team = character_team
	select_taunt_stream_player.stream = select_taunt

func handle_change_player() -> void:
	update_character_values()
	animation_tree.set("parameters/Fade/TimeSeek/seek_request", 0.0)
	animation_tree_playback.travel("Fade")

func handle_change_skin() -> void:
	update_character_values()
	animation_tree.set("parameters/ChangeSkin/TimeSeek/seek_request", 0.0)
	animation_tree_playback.travel("ChangeSkin")

func handle_selected() -> void:
	animation_tree.set("parameters/conditions/selected", true)
