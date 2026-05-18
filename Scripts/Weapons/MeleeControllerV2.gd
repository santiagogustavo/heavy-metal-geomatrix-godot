extends Item
class_name MeleeControllerV2

@export_subgroup("Properties")
@export var damage: int
@export_range(Definitions.WeaponRange.Min, Definitions.WeaponRange.Max, 0.1) var weapon_range: float = 1.7
@export var hit_push_force = 15

@export var animation_tree: AnimationTree
@export var hit_general_particle: PackedScene
@export var hit_player_particle: PackedScene

@onready var animation_tree_playback: AnimationNodeStateMachinePlayback = (
	animation_tree.get("parameters/playback")
	if animation_tree
	else null
)
@onready var trail: GPUTrail3D = $GPUTrail3D
@onready var blade: ExtendedArea3D = $Blade

var health = 100.0
var is_attacking = false
var can_hit = true
var has_collided = false

var last_player_hit_rid = null

var total_hits = 0
var MAX_HITS = 1

func _ready() -> void:
	blade.player_rid = player_rid
	blade.hit.connect(handle_hit)
	
func handle_combo_animation_changed() -> void:
	can_hit = true
	travel_to_attack_instantly()

func _process(_delta: float) -> void:
	trail.set_process(is_attacking)
	trail.visible = is_attacking
	if animation_tree:
		animation_tree.set("parameters/conditions/is_attacking", is_attacking)
		animation_tree.set("parameters/conditions/is_not_attacking", !is_attacking)

func _physics_process(_delta: float) -> void:
	blade.is_attacking = is_attacking
	blade.can_hit = can_hit

func travel_to_attack_instantly() -> void:
	if animation_tree_playback:
		animation_tree_playback.travel("Attack", true)
		animation_tree.set("parameters/Attack/TimeSeek/seek_request", 0.0)

func instantiate_hit(
	collider: CollisionObject3D,
	point: Vector3,
	normal: Vector3,
	type: int,
	is_blocking: bool
):
	var hit_instance
	if type == Definitions.SurfaceType.Hitbox and !is_blocking:
		hit_instance = hit_player_particle.instantiate()
	else:
		hit_instance = hit_general_particle.instantiate()
	vibrate_hard()
	collider.add_child(hit_instance)
	hit_instance.scale = Vector3.ONE / collider.scale
	hit_instance.global_transform.origin = point
	TransformUtils.safe_look_at(hit_instance, point + normal)

func handle_hit(body: Node3D, point: Vector3, normal: Vector3):
	if (
		body is RigidBody3D and
		body.collision_layer != Definitions.SurfaceType.BladeOrProjectile
	):
		var impulse = normal * hit_push_force
		(body as RigidBody3D).apply_central_impulse(impulse * -1)
	elif body is CharacterHitbox and can_hit:
		var player_hit_rid = (body as CharacterHitbox).player_rid
		var collided_player = GameManager.get_player(player_hit_rid)
		var push_direction: Vector3 = collided_player.global_position - global_position
		collided_player.apply_global_force(push_direction.normalized() * hit_push_force)
	
	var is_blocking: bool = false
	if "damage_taken" in body:
		if body is PristineBody:
			body.damage_taken(damage)
		elif body is CharacterHitbox:
			can_hit = false
			is_blocking = is_hitbox_player_blocking(body)
			(body as CharacterHitbox).damage_taken(
				damage,
				point,
				global_position,
				true,
				player_rid
			)
	instantiate_hit(body, point, normal, body.collision_layer, is_blocking)

func is_hitbox_player_blocking(hitbox: CharacterHitbox) -> bool:
	var hit_player: Player = GameManager.get_player(hitbox.player_rid)
	return hit_player.brain.is_blocking

func vibrate_hard() -> void:
	if player_rid != GameManager.get_player_one().get_rid():
		return
	InputManager.vibrate_controller(0, 0.0, 1.0, 0.2)
