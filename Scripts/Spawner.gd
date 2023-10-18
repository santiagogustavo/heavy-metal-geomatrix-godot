extends Node3D

@export var pickup_to_spawn: PackedScene
@export var collision_shape: CollisionShape3D
@onready var timer: Timer = $Timer

var spawn_center = Vector3.ZERO
var spawn_radius = Vector3.ZERO

func _ready():
	spawn_center = collision_shape.global_position
	spawn_radius = collision_shape.shape.size / 2
	timer.connect("timeout", _on_timer_timeout)
	spawn_at_random_position()

func _on_timer_timeout():
	spawn_at_random_position()

func spawn_at_random_position():
	var spawn_location = Vector3.ZERO
	spawn_location.x = randf_range(spawn_center.x - spawn_radius.x, spawn_center.x + spawn_radius.x)
	spawn_location.y = spawn_center.y
	spawn_location.z = randf_range(spawn_center.z - spawn_radius.z, spawn_center.z + spawn_radius.z)
	var pickup = pickup_to_spawn.instantiate()
	pickup.position = spawn_location
	add_child(pickup)
