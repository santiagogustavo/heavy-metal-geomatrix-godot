extends Node3D
class_name EnergyGunController

signal gun_shot
signal drop

@export_subgroup("Properties")
@export var item_name: String
@export var spend_amount: float
@export var damage: int
@export_range(Definitions.WeaponRange.Min, Definitions.WeaponRange.Max, 0.5) var weapon_range: float = Definitions.WeaponRange.Max

@export_subgroup("References")
@export var animation_tree: AnimationTree
@export var beam: Node3D
@export var raycasts: Array[RayCast3D] = []
@export var hit_decal: PackedScene

var player_rid: RID

var is_shooting: bool = false
var can_shoot: bool = false

var target_point: Vector3 = Vector3.ZERO
var is_dropping: bool = false

var energy: float = 100.0

var frames_per_damage: int = 5
var frames_elapsed: int = 0
var can_damage: bool = true

func _process(delta: float) -> void:
	can_shoot = energy > 0 and is_shooting
	can_damage = frames_elapsed >= frames_per_damage
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
	frames_elapsed += 1

func instantiate_hit(point: Vector3, normal: Vector3, _type: int) -> void:
	var hit_instance: Node3D
	hit_instance = hit_decal.instantiate()
	get_tree().root.add_child(hit_instance)
	hit_instance.global_transform.origin = point
	TransformUtils.safe_look_at(hit_instance, point + normal)

func detect_raycast_collision(delta: float) -> void:
	if !is_shooting:
		return
	for raycast in raycasts:
		if raycast.is_colliding() and can_damage:
			var collider: CollisionObject3D = raycast.get_collider()
			if collider.get_rid() == player_rid:
				return
			var point = raycast.get_collision_point()
			var normal = raycast.get_collision_normal()
			instantiate_hit(point, normal, collider.collision_layer)
			if collider.collision_layer == Definitions.SurfaceType.Hitbox:
				(collider as CharacterHitbox).damage_taken(damage * delta, point)
			frames_elapsed = 0
			return

func spend_fuel(delta: float) -> void:
	if !DebugCommands.full_ammo:
		energy -= delta * spend_amount
		gun_shot.emit()
		if energy < 0:
			energy = 0

func vibrate_soft() -> void:
	if player_rid != GameManager.get_player_one().get_rid():
		return
	InputManager.vibrate_controller(0, 1.0, 0.0, 0.1)
