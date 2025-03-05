extends Node3D
class_name GunController

signal gun_shot
signal drop

@export_subgroup("Properties")
@export var item_name: String
@export var bullets: int
@export var fire_rate: float
@export var burst_count: int
@export var burst_rate: float
@export var spray_amount: float
@export var zoom_factor: float = 1.0
@export var infinite_ammo: bool = false

@export_subgroup("Instances")
@export var bullet: PackedScene
@export var ejecting_brass: PackedScene

@export_subgroup("References")
@export var animation_tree: AnimationTree
@export var bullet_holes: Array[Node3D]
@export var eject_hole: Node3D

@onready var bullets_per_shot: int = bullet_holes.size()

var player_rid: RID

@export var is_shooting: bool = false
var is_shooting_locked: bool = false
var is_bursting: bool = false

var can_shoot: bool = false
var current_burst_count: int = 0

@onready var target_point: Vector3 = Vector3.FORWARD * transform.basis * 100
var is_dropping: bool = false

func _process(_delta: float) -> void:
	if is_dropping:
		return
	if bullets <= 0:
		drop.emit()
		is_dropping = true
		return
	can_shoot = is_shooting and !is_shooting_locked
	animation_tree.is_shooting = is_shooting_locked
	animation_tree.is_bursting = is_bursting
	if can_shoot:
		update_fire_rate()

func update_fire_rate() -> void:
	is_shooting_locked = true
	current_burst_count = burst_count
	get_tree().create_timer(fire_rate).connect("timeout", _unlock_fire)
	get_tree().create_timer(burst_rate).connect("timeout", _burst_fire)

func _unlock_fire() -> void:
	is_shooting_locked = false

func _burst_fire() -> void:
	if current_burst_count == 0 || bullets == 0:
		is_bursting = false
	else:
		is_bursting = true
		animation_tree.set("parameters/Shoot/TimeSeek/seek_request", 0.0)
		current_burst_count -= 1
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

func _shoot(hard: bool = false) -> void:
	if bullets == 0:
		return
	gun_shot.emit()
	if !hard:
		vibrate_soft()
	else:
		vibrate_hard()
	if !DebugCommands.full_ammo and !infinite_ammo:
		bullets -= bullets_per_shot
	for bullet_hole in bullet_holes:
		var bullet_instance: Node3D = instantiate_bullet(bullet_hole.global_position, bullet_hole.global_transform.basis)
		TransformUtils.safe_look_at(bullet_instance, target_point)
		bullet_instance.rotate_x(deg_to_rad(randf_range(-spray_amount, spray_amount)))
		bullet_instance.rotate_y(deg_to_rad(randf_range(-spray_amount, spray_amount)))
		bullet_instance.rotate_z(deg_to_rad(randf_range(-spray_amount, spray_amount)))
	if ejecting_brass:
		instantiate_brass(eject_hole.global_position, eject_hole.global_transform.basis)

func vibrate_soft() -> void:
	InputManager.vibrate_controller(0, 1.0, 0.0, 0.1)

func vibrate_hard() -> void:
	InputManager.vibrate_controller(0, 0.0, 1.0, 0.2)
