extends Node3D
class_name Spawner

@export var navigation_region: NavigationRegion3D
@export_range(1.0, 10, 1.0) var spawn_concurrent: int = 1
@export var spawn_min_distance: float = 10.0
@export var spawn_timeout: float = 5.0
@export var items_to_spawn: Array[PackedScene]
@onready var pickup = load("res://Prefabs/Pickups/Pickup.tscn")

var started: bool = false
var last_spawn_location: Vector3 = Vector3.ZERO

var spawned_pickups: Array[Node3D] = []

func _process(_delta: float) -> void:
	if (
		GameManager.current_match.round_status == MatchManager.RoundStatus.Started
		and !started
	):
		started = true
		spawn_concurrents()
	elif (
		GameManager.current_match.round_status != MatchManager.RoundStatus.Started
		and started
	):
		started = false

func get_navigation_random_position() -> Vector3:
	return NavigationServer3D.region_get_random_point(
		navigation_region.get_region_rid(),
		0,
		true
	)

func spawn_concurrents() -> void:
	spawned_pickups.clear()
	if !started:
		return
	for i in range(spawn_concurrent):
		spawn_at_random_navigation_position()
	get_tree().create_timer(spawn_timeout, false).timeout.connect(spawn_concurrents)

func spawn_at_random_navigation_position() -> void:
	var spawn_location: Vector3 = last_spawn_location
	while last_spawn_location.distance_to(spawn_location) < spawn_min_distance:
		spawn_location = get_navigation_random_position()
	last_spawn_location = spawn_location
	var random_pickup_index = randi_range(0, items_to_spawn.size() - 1)
	var item_to_spawn = items_to_spawn[random_pickup_index]
	var pickup_instance: Pickup = pickup.instantiate()
	pickup_instance.item = item_to_spawn
	pickup_instance.position = spawn_location
	pickup_instance.position.y -= 0.25
	spawned_pickups.append(pickup_instance)
	add_child(pickup_instance)
