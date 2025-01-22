extends Node3D
class_name CharacterController

@export_subgroup("Properties")
@export var character_name: String
@export var skins: Array[MeshInstance3D]
@export var default_skin: int = 0

@export_subgroup("Stats")
@export_range(1, 3) var attack: int = 1
@export_range(1, 3) var defense: int = 1
@export_range(1, 3) var agility: int = 1

@export_subgroup("Physics")
@export var speed = 7.5
@export var dashing_speed = 10.0
@export var jetpack_dashing_speed = 12.5
@export var jump_height = 10.0
@export var weight = 2.5

@export_subgroup("Inventory")
@export var body_slot: BoneAttachment3D
@export var right_hand_slot: BoneAttachment3D

# Internals
@onready var animation_tree: PlayerAnimationTree = $AnimationTree
var current_skin: int = default_skin

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
		
