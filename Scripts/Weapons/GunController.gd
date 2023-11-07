extends Node3D
class_name GunController

signal gun_shot
signal drop

@export_subgroup("Properties")
@export var bullets: int
@export var fire_rate: float
@export var burst_count: int
@export var burst_rate: float
@export var bullet: PackedScene

@onready var animation_tree = $AnimationTree
@onready var bullet_hole = $BulletHole

var is_shooting = false
var is_shooting_locked = false
var is_bursting = false

var can_shoot = false
var current_burst_count = 0

var target_point = Vector3.ZERO
var is_dropping = false

func _process(_delta):
	if is_dropping:
		return
	if bullets <= 0:
		drop.emit()
		is_dropping = true
		return
	can_shoot = is_shooting and !is_shooting_locked
	animation_tree.is_shooting = can_shoot
	animation_tree.is_bursting = is_bursting
	
	if burst_count > 0:
		update_burst()
	update_fire_rate()

func update_fire_rate():
	var scale = fire_rate / animation_tree.get_animation("Shoot").length
	animation_tree.set("parameters/Shoot/TimeScale/scale", scale)
	if can_shoot:
		is_shooting_locked = true
		get_tree().create_timer(fire_rate).connect("timeout", _unlock_fire)

func update_burst():
	if can_shoot and !is_bursting:
		is_bursting = true
		current_burst_count = burst_count
		get_tree().create_timer(burst_rate).connect("timeout", _burst_fire)

func _unlock_fire():
	is_shooting_locked = false
	if is_shooting:
		animation_tree.set("parameters/Shoot/TimeSeek/seek_request", 0.0)

func _burst_fire():
	if current_burst_count == 0:
		is_bursting = false
		return
	animation_tree.set("parameters/Shoot/TimeSeek/seek_request", 0.0)
	current_burst_count -= 1
	get_tree().create_timer(burst_rate).connect("timeout", _burst_fire)

func _shoot():
	gun_shot.emit()
	bullets -= 1
	var bullet_instance = bullet.instantiate()
	get_tree().root.add_child(bullet_instance)
	bullet_instance.position = bullet_hole.global_position
	bullet_instance.transform.basis = bullet_hole.global_transform.basis
	TransformUtils.safe_look_at(bullet_instance, target_point)
