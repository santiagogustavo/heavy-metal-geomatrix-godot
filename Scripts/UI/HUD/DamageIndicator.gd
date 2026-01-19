class_name DamageIndicator
extends Control

@export var player_camera: Camera3D
@export var target_position: Vector3
@onready var node_2d: Node2D = $Node2D

func _process(_delta: float) -> void:
	var target_screen_pos: Vector2 = player_camera.unproject_position(target_position)
	node_2d.look_at(target_screen_pos)
