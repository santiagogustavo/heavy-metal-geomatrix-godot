extends Node3D

@export var timeout = 5

@onready var area: Area3D = $Area3D
@onready var meshes: Array = find_children("", "MeshInstance3D")
@onready var animation_trees: Array = find_children("", "AnimationTree")

var is_collided = false
var color_lerp = 0
const lerp_duration = 200

const color_start = Color.WHITE
const color_end = Color.RED

func _ready():
	for mesh: MeshInstance3D in meshes:
		mesh.set_surface_override_material(0, mesh.mesh.surface_get_material(0).duplicate())

	area.connect("body_entered", _on_area_3d_body_entered)
	area.connect("body_exited", _on_area_3d_body_exited)
	get_tree().create_timer(timeout).timeout.connect(_on_timeout)

func _process(_delta):
	for mesh: MeshInstance3D in meshes:
		if is_collided:
			lerp_collision_color()
			mesh.get_surface_override_material(0).albedo_color = lerp(color_start, color_end, color_lerp)
		else:
			mesh.get_surface_override_material(0).albedo_color = color_start

func _on_timeout():
	for animation_tree: AnimationTree in animation_trees:
		animation_tree.set("parameters/conditions/is_destroying", true)
	await get_tree().create_timer(0.3).timeout
	queue_free()

func lerp_collision_color():
	color_lerp = pingpong(Time.get_ticks_msec(), lerp_duration) / lerp_duration

func _on_area_3d_body_entered(body: Node3D):
	is_collided = true
	
func _on_area_3d_body_exited(body: Node3D):
	is_collided = false
