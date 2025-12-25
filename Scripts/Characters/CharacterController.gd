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
@export var dashing_factor = 2.5
@export var dashing_speed = speed + dashing_factor
@export var jetpack_dashing_speed = dashing_speed + dashing_factor
@export var jump_height = 10.0
@export var weight = 2.5

@export_subgroup("References")
@export var hitboxes: Array[CharacterHitbox]
@export var fists: Array[FistController]
@export var jiggle_bones: Array[WiggleBone]
@export var sfx_controller: CharacterSFXController
@export var animation_tree_reference: PackedScene
@export var custom_animation_tree_reference: PackedScene

@export_subgroup("Inventory")
@export var body_slot: BoneAttachment3D
@export var right_hand_slot: BoneAttachment3D

@export_subgroup("Loadout")
@export var initial_loadout: PackedScene

@export_subgroup("Offsets")
@export var round_pivot_offset: Marker3D
@export var camera_pivot_offset: Marker3D

@onready var hitmarker: PackedScene = load("res://Prefabs/Player/Hitmarker.tscn")

# Internals
@onready var character_name: String = Definitions.CharacterNames[character]
@onready var team_name: String = Definitions.TeamNames[character_team]
var animation_tree: AnimationTree
var jiggle_physics_enabled: bool = true
var current_skin: int = default_skin

var is_dead: bool
var is_hurt: bool

var player_rid: RID

func _ready() -> void:
	if animation_tree_reference:
		animation_tree = animation_tree_reference.instantiate() as PlayerAnimationTree
	elif custom_animation_tree_reference:
		animation_tree = custom_animation_tree_reference.instantiate() as AnimationTree
	if animation_tree != null:
		add_child(animation_tree)
		animation_tree.anim_player = NodePath('./Model/AnimationPlayer')
	for hitbox in hitboxes:
		hitbox.player_rid = player_rid
		hitbox.hit.connect(take_damage_from_hitbox)
	for fist in fists:
		if fist and player_rid:
			fist.player_rid = player_rid

func _process(_delta: float) -> void:
	show_current_skin()
	update_internal_variables()
	update_skin_variables()

func update_internal_variables() -> void:
	var player: Player = GameManager.get_player(player_rid)
	if player:
		is_dead = player.health <= 0

func update_skin_variables() -> void:
	for skin: MeshInstance3D in skins:
		if skin is AnimatedTexturesMesh:
			skin.is_dead = is_dead
			skin.is_hurt = is_hurt

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

func start_talking() -> void:
	for skin: MeshInstance3D in skins:
		if skin is AnimatedTexturesMesh:
			skin.is_talking = true

func stop_talking() -> void:
	for skin: MeshInstance3D in skins:
		if skin is AnimatedTexturesMesh:
			skin.is_talking = false

func create_hitmarker(total_damage: float, is_critical: bool, hit_position: Vector3) -> void:
	var hitmarker_instance: Hitmarker = hitmarker.instantiate()
	hitmarker_instance.damage_taken = roundi(total_damage)
	hitmarker_instance.is_critical = is_critical
	get_tree().root.add_child(hitmarker_instance)
	hitmarker_instance.position.x += 0.5
	hitmarker_instance.global_position = hit_position

func take_damage_from_hitbox(
	damage_taken: float,
	damage_factor: float,
	hit_position: Vector3
) -> void:
	var total_damage: int = roundi(damage_taken * damage_factor)
	var is_critical: bool = damage_factor > 1
	if GameplaySettingsManager.hitmarkers_enabled:
		create_hitmarker(total_damage, is_critical, hit_position)
	if is_dead:
		return
	damage.emit(total_damage)
	is_hurt = true
	get_tree().create_timer(0.5).timeout.connect(func (): is_hurt = false)
	if sfx_controller:
		sfx_controller.play_hurt_sound()
	if player_rid == GameManager.get_player_one().get_rid():
		if is_critical:
			InputManager.vibrate_controller(0, 1.0, 1.0, 0.5)
		else:
			InputManager.vibrate_controller(0, 1.0, 1.0, 0.2)
