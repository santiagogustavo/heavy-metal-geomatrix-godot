extends Node3D
class_name InventoryManager

signal right_hand_pickup
signal body_pickup

var has_jetpack = false
var jetpack_fuel = 0.0
var jetpack_has_fuel = false

var has_gun = false
var ammo_total = 0
var ammo = 0

var has_melee = false
var melee_health = 0.0

var holster_timeout: float = 3.0
var is_holding_weapon: bool = false

@export var body_instance: Node3D = null
@export var right_hand_instance: Node3D = null
@export var equip_type: Definitions.EquipType = Definitions.EquipType.Body
var right_hand_item_name: String = ''

@onready var character_controller: CharacterController = $"../CharacterController"
@onready var body_slot: BoneAttachment3D = character_controller.body_slot
@onready var right_hand_slot: BoneAttachment3D = character_controller.right_hand_slot

@onready var holster_timer: Timer = Timer.new()

var is_gun_shooting = false
var is_dropping = false

func _ready() -> void:
	holster_timer.connect("timeout", _on_holster_timeout)
	add_child(holster_timer)

func _process(_delta) -> void:
	update_variables()

func update_variables():
	if body_instance != null:
		jetpack_fuel = body_instance.fuel
		jetpack_has_fuel = body_instance.fuel > 0
	else:
		has_jetpack = false
	
	if right_hand_instance != null:
		right_hand_item_name = right_hand_instance.item_name
		is_gun_shooting = false
		has_gun = right_hand_instance is GunController
		ammo = right_hand_instance.bullets if right_hand_instance is GunController else 0
		has_melee = right_hand_instance is SwordController
		melee_health = right_hand_instance.health if right_hand_instance is SwordController else 0.0
	else:
		has_gun = false
		has_melee = false

func pick_up_item(slot: Definitions.EquipType, item: PackedScene):
	if slot == Definitions.EquipType.Body:
		clear_and_instantiate_body_item(item)
	else:
		equip_type = slot
		clear_and_instantiate_right_hand_item(item)

func clear_and_instantiate_body_item(item: PackedScene):
	if body_instance:
		body_instance.queue_free()
	body_instance = item.instantiate()
	body_slot.get_node("Offset").add_child(body_instance)
	body_pickup.emit()
	if body_instance.name == 'Jetpack':
		has_jetpack = true

func clear_and_instantiate_right_hand_item(item: PackedScene):
	if right_hand_instance != null:
		right_hand_instance.queue_free()
	right_hand_instance = item.instantiate()
	right_hand_slot.get_node("Offset").add_child(right_hand_instance)
	right_hand_pickup.emit()
	if right_hand_instance is GunController:
		ammo_total = right_hand_instance.bullets
		right_hand_instance.connect("gun_shot", _on_gun_shot)
		right_hand_instance.connect("drop", _on_item_drop)

func drop_right_hand_item():
	right_hand_instance.queue_free()
	equip_type = Definitions.EquipType.Body

func _on_gun_shot():
	is_gun_shooting = true
	is_holding_weapon = true
	holster_timer.stop()
	holster_timer.start(holster_timeout)
	
func _on_holster_timeout():
	is_holding_weapon = false
	
func _on_item_drop():
	is_dropping = true
	await get_tree().create_timer(0.2).timeout
	is_dropping = false
	drop_right_hand_item()
