extends Node3D
class_name CharacterController

@export_subgroup("Properties")
@export var character_name: String

@export_subgroup("Stats")
@export var attack = 1.0
@export var defense = 1.0
@export var agility = 1.0

@export_subgroup("Physics")
@export var speed = 7.5
@export var dashing_speed = 10.0
@export var jetpack_dashing_speed = 12.5
@export var jump_height = 10.0
@export var weight = 2.5

@export_subgroup("Inventory")
@export var body_slot: BoneAttachment3D
@export var right_hand_slot: BoneAttachment3D
