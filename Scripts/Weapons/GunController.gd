extends Node3D

@export_subgroup("Properties")
@export var bullets: int
@export var fire_rate: float
@export var burst_count: int
@export var burst_rate: float
@export var bullet: PackedScene

var is_shooting = false
var target_point = Vector3.ZERO

@onready var animation_tree = $AnimationTree
@onready var bullet_hole = $BulletHole

func _process(_delta):
	animation_tree.is_shooting = is_shooting
	animation_tree.set("parameters/conditions/is_shooting", is_shooting)

func _shoot():
	var bullet_instance = bullet.instantiate()
	get_tree().root.add_child(bullet_instance)
	bullet_instance.position = bullet_hole.global_position
	bullet_instance.transform.basis = bullet_hole.global_transform.basis
	TransformUtils.safe_look_at(bullet_instance, target_point)
