extends Node
class_name PlayerBrain

var is_aiming: bool = false
var is_walking: bool = false
var is_dashing: bool = false
var is_jumping: bool = false
var is_double_jumping: bool = false
var is_shooting: bool = false
var is_attacking: bool = false
var is_picking_up: bool = false
var is_on_floor: bool = true

var can_double_jump: bool = false
var can_pickup: bool = false

var input_direction: Vector2 = Vector2.ZERO
var direction: Vector3 = Vector3.ZERO
var new_rotation: Vector3 = Vector3.ZERO

var dash_duration: float = 1.0
var dash_timeout_active: bool = false

func _process(_delta: float) -> void:
	if !is_walking:
		is_dashing = false
	if is_dashing and !dash_timeout_active:
		dash_timeout_active = true
		get_tree().create_timer(dash_duration).timeout.connect(func ():
			is_dashing = false
			dash_timeout_active = false
		)
