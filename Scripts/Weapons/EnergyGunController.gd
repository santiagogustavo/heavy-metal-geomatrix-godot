extends Node3D
class_name EnergyGunController

signal gun_shot
signal drop

@export_subgroup("Properties")
@export var item_name: String
@export var spend_amount: float
@export var damage: int

@export_subgroup("References")
@export var animation_tree: AnimationTree
@export var beam: Node3D
@export var raycast: RayCast3D
@export var hit_decal: PackedScene

var player_rid: RID

var is_shooting: bool = false
var can_shoot: bool = false

var target_point: Vector3 = Vector3.ZERO
var is_dropping: bool = false

var energy: float = 100.0

func _process(delta: float) -> void:
	can_shoot = energy > 0 and is_shooting
	animation_tree.is_shooting = can_shoot
	if is_dropping:
		return
	if can_shoot:
		vibrate_soft()
		spend_fuel(delta)
	elif energy == 0:
		is_dropping = true
		drop.emit()

func _physics_process(delta: float) -> void:
	detect_raycast_collision(delta)

func instantiate_hit(point: Vector3, normal: Vector3, _type: int):
	var hit_instance: Node3D
	hit_instance = hit_decal.instantiate()
	get_tree().root.add_child(hit_instance)
	hit_instance.global_transform.origin = point
	TransformUtils.safe_look_at(hit_instance, point + normal)

func detect_raycast_collision(delta: float):
	if is_shooting and raycast.is_colliding():
		var collider: CollisionObject3D = raycast.get_collider()
		if collider.get_rid() == player_rid:
			return
		var point = raycast.get_collision_point()
		var normal = raycast.get_collision_normal()
		instantiate_hit(point, normal, collider.collision_layer)
		if collider.collision_layer == Definitions.SurfaceType.Player:
			(collider as Player).damage_player(roundi(damage * delta))

func spend_fuel(delta: float) -> void:
	if !DebugCommands.full_ammo:
		energy -= delta * spend_amount
		gun_shot.emit()
		if energy < 0:
			energy = 0

func vibrate_soft() -> void:
	InputManager.vibrate_controller(0, 1.0, 0.0, 0.1)
