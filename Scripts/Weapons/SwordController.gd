extends Item
class_name SwordController

@export_subgroup("Properties")
@export var damage: int
@export_range(Definitions.WeaponRange.Min, Definitions.WeaponRange.Max, 0.5) var weapon_range: float = 1.75

@export var animation_tree: AnimationTree
@export var hit_general_particle: PackedScene
@export var hit_player_particle: PackedScene
@export var is_attacking = false
@export var is_swinging = false
@export var health = 100.0

@onready var trail = $GPUTrail3D
@onready var raycast: RayCast3D = $RayCast3D

var has_collided = false

func _physics_process(_delta: float) -> void:
	detect_raycast_collision()
	trail.set_process(is_attacking)
	trail.visible = is_attacking
	if animation_tree:
		animation_tree.set("parameters/conditions/is_attacking", is_attacking)
		animation_tree.set("parameters/conditions/is_not_attacking", !is_swinging)

func instantiate_hit(point: Vector3, normal: Vector3, type: int):
	var hit_instance
	if type == Definitions.SurfaceType.Hitbox:
		hit_instance = hit_player_particle.instantiate()
	else:
		hit_instance = hit_general_particle.instantiate()
	get_tree().root.add_child(hit_instance)
	vibrate_hard()
	hit_instance.global_transform.origin = point
	TransformUtils.safe_look_at(hit_instance, point + normal)

func detect_raycast_collision():
	if is_attacking and raycast.is_colliding():
		var collider: CollisionObject3D = raycast.get_collider()
		if collider.get_rid() == player_rid or has_collided:
			return
			
		if collider is RigidBody3D:
			var impulse = raycast.get_collision_normal() * 10
			(collider as RigidBody3D).apply_central_impulse(impulse * -1)

		var point = raycast.get_collision_point()
		var normal = raycast.get_collision_normal()
		instantiate_hit(point, normal, collider.collision_layer)
		if collider.collision_layer == Definitions.SurfaceType.Hitbox:
			(collider as CharacterHitbox).damage_taken(damage, point)
		has_collided = true
	else:
		has_collided = false

func vibrate_hard() -> void:
	if player_rid != GameManager.get_player_one().get_rid():
		return
	InputManager.vibrate_controller(0, 0.0, 1.0, 0.2)
