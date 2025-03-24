extends Node3D
class_name PickupController

@export_subgroup("Configs")
@export var timeout: float = 5
@export var pickup_on_press: bool = true

@export_subgroup("Pickup Definitions")
@export var equip_type: Definitions.EquipType = Definitions.EquipType.Body
@export var item: PackedScene

@onready var area: Area3D = $Area3D
@onready var meshes: Array[Node] = find_children("", "MeshInstance3D")
@onready var animation_trees: Array[Node] = find_children("", "AnimationTree")

var collider: Node3D
var is_collided: bool = false
var is_picking_up: bool = false
var color_lerp: float = 0
const lerp_duration: float = 200

const color_start: Color = Color.WHITE
const color_end: Color = Color.RED

func _ready() -> void:
	for mesh: MeshInstance3D in meshes:
		mesh.set_surface_override_material(0, mesh.mesh.surface_get_material(0).duplicate())
	area.connect("body_entered", _on_area_3d_body_entered)
	area.connect("body_exited", _on_area_3d_body_exited)
	get_tree().create_timer(timeout, false).timeout.connect(_on_timeout)

func _process(_delta: float) -> void:
	detect_player_pickup()
	for mesh: MeshInstance3D in meshes:
		if is_collided and !is_picking_up:
			lerp_collision_color()
			mesh.get_surface_override_material(0).albedo_color = lerp(color_start, color_end, color_lerp)
		else:
			mesh.get_surface_override_material(0).albedo_color = color_start

func _on_area_3d_body_entered(body: Node3D):
	if is_collided:
		return
	collider = body
	if pickup_on_press:
		is_collided = true
		collider.is_pickup_collided = true
	else:
		pickup_item()
	
func _on_area_3d_body_exited(body: Node3D):
	if collider == body:
		is_collided = false
		collider.is_pickup_collided = false
		collider = null

func detect_player_pickup():
	if collider and collider.brain.is_picking_up:
		pickup_item()

func pickup_item():
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
