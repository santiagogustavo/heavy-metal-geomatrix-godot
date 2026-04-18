class_name DamageIndicator
extends Control

@export var player_camera: Camera3D
@export var target_position: Vector3
@onready var damage_indicator_look_at: Node3D = Node3D.new()

func _ready() -> void:
	var player = GameManager.get_player_one()
	player.add_child(damage_indicator_look_at)

func _process(_delta: float) -> void:
	damage_indicator_look_at.look_at(target_position, Vector3.UP)
	rotation = -damage_indicator_look_at.rotation.y
