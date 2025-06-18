extends Node3D
class_name Pickup

@export_subgroup("Configs")
@export var timeout: float = 5

@export_subgroup("Properties")
@export var animation_trees: Array[AnimationTree] = []

@export_subgroup("Pickup Definitions")
@export var item: PackedScene

@onready var item_small: Node3D = $Meshes/ItemSmall
@onready var item_big: Node3D = $Meshes/ItemBig
@onready var name_label: Label = $TitleViewport/Control/Label
@onready var splash_rect: TextureRect = $SplashViewport/Control/Control/Splash
@onready var splash_big_rect: TextureRect = $SplashBigViewport/Control/Control/Splash
@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var collision_area: Area3D = $Area3D

# COLOR ITEMS #
@onready var base_1: MeshInstance3D = $Meshes/Base/object_0
@onready var base_2: MeshInstance3D = $Meshes/Base/object_0_001
@onready var item_small_edge: MeshInstance3D = $Meshes/ItemSmall/object_0_002
@onready var item_big_edge: MeshInstance3D = $Meshes/ItemBig/object_0_001
@onready var inner_ring: MeshInstance3D = $Meshes/"Inner Ring"
@onready var outer_ring: MeshInstance3D = $Meshes/"Outer Ring"
@onready var base_light: OmniLight3D = $BaseLight
@onready var title_bg: TextureRect = $TitleViewport/Control/BG
@onready var splash_bg: TextureRect = $SplashViewport/Control/BG
@onready var splash_big_bg: TextureRect = $SplashBigViewport/Control/BG

var item_instance: Item
var item_name: String
var equip_type: Definitions.EquipType
var pickup_color: PickupColor
var is_big: bool = false
var pickup_on_press: bool = true

enum PickupColor {
	Red,
	Green,
	Blue
}

var color_hashes: Dictionary = {
	PickupColor.Red: "ff2f42",
	PickupColor.Green: "68fe9b",
	PickupColor.Blue: "2d78ff"
}

var current_player_collided: Player
var is_picking_up: bool = false

var color_lerp: float = 0
const lerp_duration: float = 200
const color_start: Color = Color.WHITE
const color_end: Color = Color.RED

func _ready() -> void:
	item_instance = item.instantiate() as Item
	item_name = item_instance.item_name
	equip_type = item_instance.equip_type
	collision_area.connect("body_entered", _on_area_3d_body_entered)
	collision_area.connect("body_exited", _on_area_3d_body_exited)
	compute_pickup_attributes()
	set_label_text()
	set_splash_texture_and_rotation()
	set_item_size()
	get_tree().create_timer(timeout, false).timeout.connect(_on_timeout)

func _process(_delta: float) -> void:
	detect_player_pickup()
	lerp_collision_color()
	if current_player_collided and !is_picking_up:
		set_color_theme(lerp(color_start, color_end, color_lerp))
	else:
		set_color_theme(color_hashes[pickup_color])

func _on_timeout():
	for animation_tree: AnimationTree in animation_trees:
		animation_tree.set("parameters/conditions/is_destroying", true)
	get_tree().create_timer(0.5).timeout.connect(queue_free)

func _on_area_3d_body_entered(body: Node3D):
	if current_player_collided or is_picking_up:
		return
	current_player_collided = body
	current_player_collided.is_pickup_collided = true
	if !pickup_on_press:
		pickup_item()
	
func _on_area_3d_body_exited(body: Node3D):
	if current_player_collided == body:
		current_player_collided.is_pickup_collided = false
		current_player_collided = null

func compute_pickup_attributes() -> void:
	match equip_type:
		Definitions.EquipType.Body:
			pickup_color = PickupColor.Green
			pickup_on_press = false
			return
		Definitions.EquipType.WeaponSingle:
			pickup_color = PickupColor.Blue
			return
		Definitions.EquipType.WeaponDouble:
			pickup_color = PickupColor.Blue
			is_big = true
			return
		Definitions.EquipType.MeleeLight:
			pickup_color = PickupColor.Red
			is_big = true
			return
		Definitions.EquipType.MeleeHeavy:
			pickup_color = PickupColor.Red
			is_big = true
			return

func pickup_item():
	current_player_collided.inventory_manager.pick_up_item(equip_type, item)
	is_picking_up = true
	for animation_tree: AnimationTree in animation_trees:
		animation_tree.set("parameters/conditions/is_picking_up", true)
	get_tree().create_timer(0.2).timeout.connect(queue_free)

func set_item_size() -> void:
	if is_big:
		item_big.visible = true
		item_small.queue_free()
	else:
		item_small.visible = true
		item_big.queue_free()

func set_label_text() -> void:
	name_label.text = item_name

func set_splash_texture_and_rotation() -> void:
	splash_rect.texture = item_instance.splash
	splash_big_rect.texture = item_instance.splash

func set_color_theme(theme_color: Color) -> void:
	if item_small:
		item_small_edge.get_surface_override_material(0).set("albedo_color", theme_color)
	if item_big:
		item_big_edge.get_surface_override_material(0).set("albedo_color", theme_color)
	base_1.get_surface_override_material(0).set("albedo_color", theme_color)
	base_2.get_surface_override_material(0).set("albedo_color", theme_color)
	inner_ring.get_surface_override_material(0).set("shader_parameter/tip_color", theme_color)
	outer_ring.get_surface_override_material(0).set("shader_parameter/tip_color", theme_color)
	base_light.light_color = theme_color
	title_bg.modulate = theme_color
	splash_bg.modulate = theme_color
	splash_big_bg.modulate = theme_color
	particles.process_material.set("color", theme_color)

func detect_player_pickup():
	if !current_player_collided:
		return
	if current_player_collided.brain.is_picking_up and !is_picking_up:
		is_picking_up = true
		pickup_item()

func lerp_collision_color():
	color_lerp = pingpong(Time.get_ticks_msec(), lerp_duration) / lerp_duration
