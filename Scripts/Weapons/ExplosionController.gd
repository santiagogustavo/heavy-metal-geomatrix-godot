extends Area3D
class_name ExplosionController

@export var damage: int = 20
@export var push_force: float = 20

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var collision_radius: float = (collision_shape.shape as SphereShape3D).radius

var emissor_rid: RID
var players_damaged: Array[RID] = []

func _ready() -> void:
	body_entered.connect(apply_damage_to_player)

func apply_damage_to_player(body: Node3D) -> void:
	if body is RigidBody3D:
		var normal = global_position - body.global_position
		var impulse = normal * push_force
		(body as RigidBody3D).apply_central_impulse(impulse)
	elif body is CharacterHitbox:
		var player_rid: RID = (body as CharacterHitbox).player_rid
		if players_damaged.has(player_rid):
			return
		else:
			players_damaged.append(player_rid)
		var player: Player = GameManager.get_player(player_rid)
		var distance_from_center = global_position.distance_to(player.global_position)
		var distance_percentual_to_center = (collision_radius - distance_from_center) / collision_radius
		distance_percentual_to_center = clampf(distance_percentual_to_center, 0.0, 1.0)
		(body as CharacterHitbox).damage_taken(damage * distance_percentual_to_center, global_position, global_position)
		var push_direction: Vector3 = player.global_position - global_position
		player.apply_global_force(push_direction.normalized() * push_force)
