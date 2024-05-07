extends Node3D
class_name InputManager

signal shoot
signal drop

var inventory_manager: InventoryManager

var is_shoot_locked: bool = false
var current_burst_count: int = 0

func _process(_delta):
	if !inventory_manager:
		return
	if inventory_manager.has_gun:
		update_shoot()
	if inventory_manager.right_hand_instance != null:
		update_drop()

func update_drop():
	if Input.is_action_pressed("drop"):
		drop.emit()

# GUN SIGNALS #
func _unlock_fire():
	is_shoot_locked = false

func update_burst():
	if inventory_manager.right_hand_instance == null:
		return
	if current_burst_count == inventory_manager.right_hand_instance.burst_count:
		current_burst_count = 0
	else:
		current_burst_count += 1
		shoot.emit()
		get_tree() \
			.create_timer(inventory_manager.right_hand_instance.burst_rate) \
			.connect("timeout", update_burst)

func update_shoot():
	if Input.is_action_pressed("shoot") and !is_shoot_locked:
		is_shoot_locked = true
		shoot.emit()
		get_tree() \
			.create_timer(inventory_manager.right_hand_instance.fire_rate) \
			.connect("timeout", _unlock_fire)
		if inventory_manager.right_hand_instance.burst_count > 0:
			update_burst()
