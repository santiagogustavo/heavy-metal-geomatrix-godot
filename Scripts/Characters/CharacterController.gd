extends Node3D
class_name CharacterController

signal damage

@export_subgroup("Properties")
@export var character: Definitions.Characters
@export var character_team: Definitions.Teams
@export var avatar_big: Texture2D
@export var avatar_small: Texture2D
@export var skins: Array[MeshInstance3D]
@export var default_skin: int = 0

@export_subgroup("Stats")
@export_range(1, 3) var stat_speed: int = 1
@export_range(1, 3) var stat_power: int = 1
@export_range(1, 3) var stat_vitality: int = 1

@export_subgroup("Physics")
@export var speed = 7.5
@export var dashing_speed = 10.0
@export var jetpack_dashing_speed = 12.5
@export var jump_height = 10.0
@export var weight = 2.5

@export_subgroup("References")
@export var hitboxes: Array[CharacterHitbox]
@export var jiggle_bones: Array[WiggleBone]
@export var sfx_controller: CharacterSFXController
@export var animation_tree_reference: PackedScene
@export var custom_animation_tree_reference: PackedScene

@export_subgroup("Inventory")
@export var body_slot: BoneAttachment3D
@export var right_hand_slot: BoneAttachment3D

@export_subgroup("Loadout")
@export var initial_loadout: PackedScene
@export var initial_loadout_slot: Definitions.EquipType

# Internals
@onready var character_name: String = Definitions.CharacterNames[character]
@onready var team_name: String = Definitions.TeamNames[character_team]
var animation_tree: AnimationTree
var jiggle_physics_enabled: bool = true
var current_skin: int = default_skin

func _ready() -> void:
	if animation_tree_reference:
		animation_tree = animation_tree_reference.instantiate() as PlayerAnimationTree
	elif custom_animation_tree_reference:
		animation_tree = custom_animation_tree_reference.instantiate() as AnimationTree
	if animation_tree != null:
		add_child(animation_tree)
		animation_tree.anim_player = NodePath('./Model/AnimationPlayer')
	for hitbox in hitboxes:
		hitbox.hit.connect(take_damage_from_hitbox)

func _process(_delta: float) -> void:
	show_current_skin()

func show_current_skin() -> void:
	var index: int = 0
	for skin: MeshInstance3D in skins:
		if current_skin == index:
			skin.visible = true
		else:
			skin.visible = false
		index += 1

func reset_jiggle_bones() -> void:
	for bone: WiggleBone in jiggle_bones:
		bone.reset()

func take_damage_from_hitbox(damage_taken: float, damage_factor: float) -> void:
	var total_damage: int = roundi(damage_taken * damage_factor)
	var is_critical: bool = damage_factor > 1
	damage.emit(total_damage, is_critical)
