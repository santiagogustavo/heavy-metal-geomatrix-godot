extends Node3D
class_name GunController

signal gun_shot
signal gun_burst
signal drop

@export_subgroup("Properties")
@export var bullets: int
@export var bullets_per_shot: int = 1
@export var fire_rate: float
@export var burst_count: int
@export var burst_rate: float
@export var spray_amount: float

@export_subgroup("Instances")
@export var bullet: PackedScene
@export var ejecting_brass: PackedScene

@export_subgroup("References")
@export var animation_tree: AnimationTree
@export var bullet_holes: Array[Node3D]
@export var eject_hole: Node3D

var is_shooting: bool = false
var is_shooting_locked: bool = false
var is_bursting: bool = false

var can_shoot: bool = false
var current_burst_count: int = 0

var target_point: Vector3 = Vector3.ZERO
var is_dropping: bool = false

func _process(_delta) -> void:
	if is_dropping:
		return
	if bullets <= 0:
		drop.emit()
		is_dropping = true
		return
	can_shoot = is_shooting and !is_shooting_locked
	animation_tree.is_shooting = can_shoot
	animation_tree.is_bursting = is_bursting
	
	if burst_count > 0 and bullets > 0:
		update_burst()
	update_fire_rate()

func update_fire_rate() -> void:
	var animation_scale = fire_rate / animation_tree.get_animation("Shoot").length
	animation_tree.set("parameters/Shoot/TimeScale/scale", animation_scale)
	if can_shoot:
		is_shooting_locked = true
		get_tree().create_timer(fire_rate).connect("timeout", _unlock_fire)

func update_burst() -> void:
	if can_shoot and !is_bursting:
		is_bursting = true
		current_burst_count = burst_count
		get_tree().create_timer(burst_rate).connect("timeout", _burst_fire)

func _unlock_fire() -> void:
	is_shooting_locked = false
	if is_shooting:
		animation_tree.set("parameters/Shoot/TimeSeek/seek_request", 0.0)

func _burst_fire() -> void:
	if current_burst_count == 0:
		is_bursting = false
		return
	animation_tree.set("parameters/Shoot/TimeSeek/seek_request", 0.0)
	current_burst_count -= 1
	gun_burst.emit()
	get_tree().create_timer(burst_rate).connect("timeout", _burst_fire)

func instantiate_bullet(newPosition: Vector3, newBasis: Basis) -> Node3D:
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = newPosition
	bullet_instance.transform.basis = newBasis
	get_tree().root.add_child(bullet_instance)
	return bullet_instance

func instantiate_brass(newPosition: Vector3, newBasis: Basis) -> Node3D:
	var brass_instance = ejecting_brass.instantiate()
	brass_instance.position = newPosition
	brass_instance.transform.basis = newBasis
	get_tree().root.add_child(brass_instance)
	return brass_instance

func _shoot() -> void:
	if bullets == 0:
		return
	gun_shot.emit()
	bullets -= bullets_per_shot
	for bullet_hole in bullet_holes:
		var bullet_instance: Node3D = instantiate_bullet(bullet_hole.global_position, bullet_hole.global_transform.basis)
		TransformUtils.safe_look_at(bullet_instance, target_point)
		bullet_instance.rotate_x(deg_to_rad(randf_range(-spray_amount, spray_amount)))
		bullet_instance.rotate_y(deg_to_rad(randf_range(-spray_amount, spray_amount)))
		bullet_instance.rotate_z(deg_to_rad(randf_range(-spray_amount, spray_amount)))
	instantiate_brass(eject_hole.global_position, eject_hole.global_transform.basis)
