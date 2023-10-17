extends Node3D
class_name InventoryManager

@export var has_jetpack = false
@export var jetpack_has_fuel = false

@onready var character_controller: CharacterController = $"../CharacterController"
@onready var body_slot: BoneAttachment3D = character_controller.body_slot

@export var body_instance: Node3D

func _process(_delta):
	if body_instance:
		jetpack_has_fuel = body_instance.fuel > 0

func pick_up_item(slot: Definitions.EquipType, item: PackedScene):
	if slot == Definitions.EquipType.Body:
		if body_instance:
			body_instance.queue_free()
		body_instance = item.instantiate()
		body_slot.add_child(body_instance)
		if body_instance.name == 'Jetpack':
			has_jetpack = true
