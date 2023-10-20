extends Node3D

@export_subgroup("Configs")
@export var timeout: float = 5
@export var pickup_on_press: bool = true

@export_subgroup("Pickup Definitions")
@export var equip_type: Definitions.EquipType = Definitions.EquipType.Body
@export var item: PackedScene

@onready var area: Area3D = $Area3D
@onready var meshes: Array = find_children("", "MeshInstance3D")
@onready var animation_trees: Array = find_children("", "AnimationTree")

var collider
var is_collided = false
var is_picking_up = false
var color_lerp = 0
const lerp_duration = 200

const color_start = Color.WHITE
const color_end = Color.RED

func _ready():
	for mesh: MeshInstance3D in meshes:
		mesh.set_surface_override_material(0, mesh.mesh.surface_get_material(0).duplicate())

	area.connect("body_entered", _on_area_3d_body_entered)
	area.connect("body_exited", _on_area_3d_body_exited)
	get_tree().create_timer(timeout, false).timeout.connect(_on_timeout)

func _process(_delta):
	detect_player_pickup()
	for mesh: MeshInstance3D in meshes:
		if is_collided and !is_picking_up:
			lerp_collision_color()
			mesh.get_surface_override_material(0).albedo_color = lerp(color_start, color_end, color_lerp)
		else:
			mesh.get_surface_override_material(0).albedo_color = color_start

func detect_player_pickup():
	if collider:
		if collider.is_picking_up:
			_on_pickup()

func _on_pickup():
	if collider:
		collider.inventory_manager.pick_up_item(equip_type, item)
		collider.is_pickup_collided = false
		is_picking_up = true

	for animation_tree: AnimationTree in animation_trees:
		animation_tree.set("parameters/conditions/is_picking_up", true)
	await get_tree().create_timer(0.2).timeout
	queue_free()

func _on_timeout():
	for animation_tree: AnimationTree in animation_trees:
		animation_tree.set("parameters/conditions/is_destroying", true)
	await get_tree().create_timer(0.3).timeout
	queue_free()

func lerp_collision_color():
	color_lerp = pingpong(Time.get_ticks_msec(), lerp_duration) / lerp_duration

func _on_area_3d_body_entered(body: Node3D):
	collider = body
	if pickup_on_press:
		is_collided = true
		collider.is_pickup_collided = true
	else:
		_on_pickup()
	
func _on_area_3d_body_exited(_body: Node3D):
	is_collided = false
	if collider:
		collider.is_pickup_collided = false
		collider = null
