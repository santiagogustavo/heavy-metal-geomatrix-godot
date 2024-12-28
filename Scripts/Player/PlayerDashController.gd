extends GPUParticles3D

@export_subgroup("Externals")
@export var is_dashing: bool = false
@export var input_direction: Vector2 = Vector2.ZERO
@export var player_velocity: Vector3 = Vector3.ZERO

func _process(_delta: float) -> void:
	emitting = is_dashing
	process_material.direction = -Vector3(
		input_direction.x,
		clampf(player_velocity.y / Definitions.Gravity, -1, 1),
		input_direction.y
	)
