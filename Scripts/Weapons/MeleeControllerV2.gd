extends Item
class_name MeleeControllerV2

@export_subgroup("Properties")
@export var damage: int
@export_range(Definitions.WeaponRange.Min, Definitions.WeaponRange.Max, 0.1) var weapon_range: float = 1.7

@export var animation_tree: AnimationTree
@export var hit_general_particle: PackedScene
@export var hit_player_particle: PackedScene

@onready var trail: GPUTrail3D = $GPUTrail3D
@onready var rigid_body: RigidBody3D = $RigidBody3D

var health = 100.0
var is_attacking = false
var is_swinging = false
var has_collided = false

var last_player_hit_rid = null

func _physics_process(_delta: float) -> void:
	var collision: KinematicCollision3D = rigid_body.move_and_collide(transform.basis * Vector3(0, 0, 0))
	if is_swinging:
		last_player_hit_rid = null
	if is_attacking and collision:
		collide(collision)
		has_collided = true
	else:
		has_collided = false
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

func collide(collision: KinematicCollision3D):
	var collider: CollisionObject3D = collision.get_collider()
	var is_self_player = (collider is CharacterHitbox) and (collider as CharacterHitbox).player_rid == player_rid
	if (
		!collider
		or has_collided
		or is_self_player
	):
		return
	
	var point: Vector3 = collision.get_position()
	var normal: Vector3 = collision.get_normal()
	
	if collider is RigidBody3D:
		var impulse = normal * 30
		(collider as RigidBody3D).apply_central_impulse(impulse * -1)
	elif collider is CharacterHitbox:
		var player_hit_rid = (collider as CharacterHitbox).player_rid
		if last_player_hit_rid == player_hit_rid:
			return
		last_player_hit_rid = player_hit_rid
		var collided_player = GameManager.get_player(player_hit_rid)
		var push_direction: Vector3 = collided_player.global_position - global_position
		collided_player.apply_global_force(push_direction.normalized() * 30)
	
	if collider.collision_layer == Definitions.SurfaceType.Hitbox:
		(collider as CharacterHitbox).damage_taken(damage, collision.get_position(), point, true)
	instantiate_hit(point, normal, collider.collision_layer)

func vibrate_hard() -> void:
	if player_rid != GameManager.get_player_one().get_rid():
		return
	InputManager.vibrate_controller(0, 0.0, 1.0, 0.2)
