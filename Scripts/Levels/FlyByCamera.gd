extends Node3D
class_name FlyByCamera

@export var start_position: Vector3 = Vector3.ZERO
@export var start_rotation: Vector3 = Vector3.ZERO
@onready var camera: Camera3D = $Camera3D

var input_direction: Vector2 = Vector2.ZERO
var direction: Vector3 = Vector3.ZERO
var mouse_rotation_factor: Vector2 = Vector2.ZERO
var stick_rotation_factor: Vector2 = Vector2.ZERO

func _ready() -> void:
	global_position = start_position
	global_rotation = start_rotation
	camera.make_current()

func _process(_delta: float) -> void:
	input_compute_movement()
	input_compute_look_stick()
	compute_movement()
	compute_rotation()
	mouse_rotation_factor = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_rotation_factor.y = deg_to_rad(-event.relative.x) * InputSettingsManager.mouse_horizontal_sensitivity
		mouse_rotation_factor.x = deg_to_rad(-event.relative.y) * InputSettingsManager.mouse_vertical_sensitivity

func input_compute_movement() -> void:
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var input_vertical: float = 1.0 if Input.is_action_pressed("jump") else 0.0
	input_vertical = -1.0 if Input.is_action_pressed("crouch") else input_vertical
	direction = (
		transform.basis
		* Vector3(input_direction.x, input_vertical, input_direction.y)
	).normalized()

func input_compute_look_stick() -> void:
	var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down", 0.2)
	stick_rotation_factor.y = deg_to_rad(-look_dir.x) * InputSettingsManager.stick_horizontal_sensitivity
	stick_rotation_factor.x = deg_to_rad(-look_dir.y) * InputSettingsManager.stick_vertical_sensitivity

func compute_movement() -> void:
	var current_speed: float = 0.1
	position += direction * current_speed * (camera.transform.basis)

func compute_rotation() -> void:
	rotation.y += (mouse_rotation_factor + stick_rotation_factor).y
	rotation.x += (mouse_rotation_factor + stick_rotation_factor).x
