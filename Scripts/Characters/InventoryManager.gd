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

@export var body_instance: Node3D = null
@export var right_hand_instance: Node3D = null
@export var equip_type: Definitions.EquipType = Definitions.EquipType.Body

@onready var character_controller: CharacterController = $"../CharacterController"
@onready var body_slot: BoneAttachment3D = character_controller.body_slot
@onready var right_hand_slot: BoneAttachment3D = character_controller.right_hand_slot

var is_dropping = false

func _process(_delta):
	update_variables()

func update_variables():
	if body_instance != null:
		jetpack_fuel = body_instance.fuel
		jetpack_has_fuel = body_instance.fuel > 0
	else:
		has_jetpack = false
	
	if right_hand_instance and right_hand_instance != null:
		ammo = right_hand_instance.bullets if right_hand_instance is GunController else 0
		melee_health = right_hand_instance.health if right_hand_instance is SwordController else 0.0
	else:
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
	if right_hand_instance is GunController:
		has_gun = true
		has_melee = false
		ammo_total = right_hand_instance.bullets
		right_hand_instance.connect("gun_drop", _on_item_drop)
	elif right_hand_instance is SwordController:
		has_gun = false
		has_melee = true
		right_hand_instance.connect("sword_drop", _on_item_drop)
	right_hand_pickup.emit()

func drop_right_hand_item():
	has_gun = false
	has_melee = false
	if right_hand_instance != null:
		right_hand_instance.queue_free()
		right_hand_instance = null
	equip_type = Definitions.EquipType.Body
	
func _on_item_drop():
	is_dropping = true
	await get_tree().create_timer(0.2).timeout
	is_dropping = false
	drop_right_hand_item()
