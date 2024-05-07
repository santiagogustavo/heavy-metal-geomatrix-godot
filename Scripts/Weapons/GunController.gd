extends Node3D
class_name GunController

signal gun_shot
signal gun_drop

@export_subgroup("Properties")
@export var bullets: int
@export var fire_rate: float
@export var burst_count: int
@export var burst_rate: float
@export var bullet: PackedScene

@onready var animation_tree = $AnimationTree
@onready var bullet_hole = $BulletHole

var target_point: Vector3 = Vector3.ZERO
var is_dropping: bool = false

func _ready():
	var animation_scale = fire_rate / animation_tree.get_animation("Shoot").length
	animation_tree.set("parameters/Shoot/TimeScale/scale", animation_scale)

func _process(_delta):
	if is_dropping:
		return
	if bullets <= 0:
		bullets = 0
		drop()

func drop():
	is_dropping = true
	gun_drop.emit()

func shoot():
	if is_dropping:
		return
	animation_tree.get("parameters/playback").travel("Shoot")
	animation_tree.set("parameters/Shoot/TimeSeek/seek_request", 0.0)
	bullets -= 1
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = bullet_hole.global_position
	bullet_instance.transform.basis = bullet_hole.global_transform.basis
	get_tree().root.add_child(bullet_instance)
	TransformUtils.safe_look_at(bullet_instance, target_point)
