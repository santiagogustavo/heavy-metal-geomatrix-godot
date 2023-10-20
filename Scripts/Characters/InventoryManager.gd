extends Node3D
class_name InventoryManager

@export var has_jetpack = false
@export var jetpack_has_fuel = false

@onready var character_controller: CharacterController = $"../CharacterController"
@onready var body_slot: BoneAttachment3D = character_controller.body_slot
@onready var right_hand_slot: BoneAttachment3D = character_controller.right_hand_slot

@export var body_instance: Node3D
@export var right_hand_instance: Node3D

@export var equip_type: Definitions.EquipType = Definitions.EquipType.Body

func _process(_delta):
	if body_instance:
		jetpack_has_fuel = body_instance.fuel > 0

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
	if body_instance.name == 'Jetpack':
		has_jetpack = true

func clear_and_instantiate_right_hand_item(item: PackedScene):
	if right_hand_instance:
		right_hand_instance.queue_free()
	right_hand_instance = item.instantiate()
	right_hand_slot.get_node("Offset").add_child(right_hand_instance)

func drop_right_hand_item():
	right_hand_instance.queue_free()
	equip_type = Definitions.EquipType.Body
