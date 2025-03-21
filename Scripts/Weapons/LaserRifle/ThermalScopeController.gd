extends Node3D

@export var scope_camera: Camera3D
@export var animation_tree: AnimationTree

@onready var parent_controller: GunController = get_parent()
@onready var player_one: Player = GameManager.get_player_one()

func _ready() -> void:
	if !player_one or parent_controller.player_rid != player_one.get_rid():
		queue_free()

func _process(_delta: float) -> void:
	scope_camera.fov = player_one.camera.fov
	scope_camera.global_position = player_one.camera.global_position
	scope_camera.global_rotation = player_one.camera.global_rotation
	var is_aiming: bool = player_one.brain.is_aiming
	animation_tree.set("parameters/conditions/is_aiming", is_aiming)
	animation_tree.set("parameters/conditions/is_not_aiming", !is_aiming)
