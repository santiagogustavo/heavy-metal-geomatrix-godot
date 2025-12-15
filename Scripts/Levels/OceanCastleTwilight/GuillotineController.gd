extends Node3D

@onready var skeleton: Skeleton3D = $StaticBody3D/Guillotine/Armature/Skeleton3D
@onready var physical_bone_simulator: PhysicalBoneSimulator3D = $StaticBody3D/Guillotine/Armature/Skeleton3D/PhysicalBoneSimulator3D

func _ready() -> void:
	skeleton.physical_bones_start_simulation()
	physical_bone_simulator.physical_bones_start_simulation()
