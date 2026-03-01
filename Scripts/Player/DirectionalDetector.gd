extends Area3D
class_name DirectionalDetector

signal hit

enum HitDirection {
	Front,
	Back,
	Left,
	Right
}

@export var hit_direction: HitDirection

func emit_hit() -> void:
	hit.emit(hit_direction)
