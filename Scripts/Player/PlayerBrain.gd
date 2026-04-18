extends Node
class_name PlayerBrain

var is_aiming: bool = false
var is_walking: bool = false
var is_dashing: bool = false
var is_jumping: bool = false
var is_double_jumping: bool = false
var is_shooting: bool = false
var is_attacking: bool = false
var is_blocking: bool = false
var is_picking_up: bool = false
var is_on_floor: bool = true
var is_free_look: bool = false
var should_look_at_target: bool = false

var is_movement_locked: bool = false

var can_double_jump: bool = false
var can_pickup: bool = false

var input_direction: Vector2 = Vector2.ZERO
var direction: Vector3 = Vector3.ZERO
var new_rotation: Vector3 = Vector3.ZERO

var dash_duration: float = 1.0
var dash_timeout_active: bool = false

var equip_type: Definitions.EquipType = Definitions.EquipType.Body

func _process(_delta: float) -> void:
	is_free_look = GameplaySettingsManager.free_look_enabled
	is_blocking = is_aiming and (
		equip_type == Definitions.EquipType.MeleeLight or
		equip_type == Definitions.EquipType.MeleeHeavy
	)
	should_look_at_target = (
		!is_free_look or
		is_aiming or
		is_walking or
		is_shooting or
		is_attacking
	)
	if !is_walking or is_movement_locked:
		is_dashing = false
	if is_dashing and !dash_timeout_active:
		dash_timeout_active = true
		get_tree().create_timer(dash_duration).timeout.connect(func ():
			is_dashing = false
			dash_timeout_active = false
		)

func reset_brain() -> void:
	is_aiming = false
	is_walking = false
	is_dashing = false
	is_jumping = false
	is_double_jumping = false
	is_shooting = false
	is_attacking = false
	is_blocking = false
	is_picking_up = false
	is_on_floor = true
	is_movement_locked = false
	should_look_at_target = false
	dash_timeout_active = false
