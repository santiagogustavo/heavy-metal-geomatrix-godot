extends Node3D

@export var pickups_to_spawn: Array[PackedScene]
@export var collision_shapes: Array[CollisionShape3D]
@onready var timer: Timer = $Timer

var spawn_center: Array[Vector3]
var spawn_radius: Array[Vector3]

func _ready():
	for collision_shape in collision_shapes:
		spawn_center.push_front(collision_shape.global_position)
		spawn_radius.push_front(collision_shape.shape.size / 2)
	timer.connect("timeout", _on_timer_timeout)
	spawn_at_random_position()

func _on_timer_timeout():
	spawn_at_random_position()

func spawn_at_random_position():
	for index in collision_shapes.size():
		var spawn_location = Vector3.ZERO
		spawn_location.x = randf_range(
			spawn_center[index].x - spawn_radius[index].x,
			spawn_center[index].x + spawn_radius[index].x
		)
		spawn_location.y = spawn_center[index].y
		spawn_location.z = randf_range(
			spawn_center[index].z - spawn_radius[index].z,
			spawn_center[index].z + spawn_radius[index].z
		)
		var random_pickup_index = randi_range(0, pickups_to_spawn.size() - 1)
		var pickup_to_spawn = pickups_to_spawn[random_pickup_index]
		var pickup = pickup_to_spawn.instantiate()
		pickup.position = spawn_location
		add_child(pickup)
