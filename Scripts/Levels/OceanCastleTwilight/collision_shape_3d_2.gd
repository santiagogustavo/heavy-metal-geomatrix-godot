extends CollisionShape3D

func _ready() -> void:
	var offset = position
	position = Vector3.ZERO
	var points = (shape as ConvexPolygonShape3D).points
	var offset_points = []
	for point in points:
		offset_points.append(point - offset)
	shape.points = offset_points
