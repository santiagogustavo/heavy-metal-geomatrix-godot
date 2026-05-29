extends Node3D

@onready var raycast: RayCast3D = $RayCast3D
@onready var beam: MeshInstance3D = $MeshInstance3D
@onready var dot: GPUParticles3D = $Dot

func _process(_delta: float) -> void:
	if raycast.is_colliding():
		var point = to_local(raycast.get_collision_point())
		beam.mesh.height = point.z
		beam.position.z = point.z / 2
		dot.emitting = true
		dot.position = point
	else:
		dot.emitting = false
		beam.mesh.height = raycast.target_position.z
		beam.position.z = raycast.target_position.z / 2
