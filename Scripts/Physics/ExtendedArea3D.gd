extends Area3D
class_name ExtendedArea3D

signal hit

var is_attacking: bool = false
var can_hit: bool = false
var player_rid: RID

@onready var raycast: RayCast3D = RayCast3D.new()
@onready var ready_listener: int = ready.connect(handle_ready)
@onready var body_entered_listener: int = body_entered.connect(handle_body_entered)

func handle_ready() -> void:
	add_child(raycast)
	raycast.collision_mask = collision_mask

func compute_can_damage_hit(body: Node) -> bool:
	var is_body_self_owned: bool = (
		body.player_rid == player_rid
		if "player_rid" in body
		else false
	)
	return (
		!is_body_self_owned
		and is_attacking
		and can_hit
	)

func handle_body_entered(body: Node3D):
	if !compute_can_damage_hit(body):
		return
	raycast.global_position = global_position
	raycast.look_at(body.global_position)
	can_hit = false
	var point: Vector3 = raycast.get_collision_point()
	var normal: Vector3 = raycast.get_collision_normal()
	hit.emit(body, point, normal)
