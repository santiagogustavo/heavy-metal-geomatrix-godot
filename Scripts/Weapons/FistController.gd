extends RigidBody3D
class_name FistController

@export var damage: int = 2
@export var hit_decal: PackedScene

var is_attacking: bool = false
var can_hit: bool = false

var player_rid: RID

func _physics_process(_delta: float):
	var collision: KinematicCollision3D = move_and_collide(Vector3.ZERO)
	if collision:
		collide(collision)

func instantiate_hit(point: Vector3, normal: Vector3):
	var hit_instance = hit_decal.instantiate()
	get_tree().root.add_child(hit_instance)
	hit_instance.global_transform.origin = point
	TransformUtils.safe_look_at(hit_instance, point + normal)

func collide(collision: KinematicCollision3D):
	var collider: CollisionObject3D = collision.get_collider()
	if (collider as CharacterHitbox).player_rid == player_rid or !is_attacking or !can_hit:
		return
	can_hit = false
	(collider as CharacterHitbox).damage_taken(damage, collision.get_position())
	var point: Vector3 = collision.get_position()
	var normal: Vector3 = collision.get_normal()
	instantiate_hit(point, normal)
