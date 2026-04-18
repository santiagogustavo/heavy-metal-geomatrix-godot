extends Control

@onready var name_label: Label = $Labels/Name
@onready var mode_label: Label = $Labels/Mode

func _process(_delta: float) -> void:
	var player: Player = GameManager.get_player_one()
	var has_player = player and player != null
	var has_weapon = (
		has_player and
		player.inventory_manager.right_hand_instance and
		player.inventory_manager.right_hand_instance is GunControllerV2 and
		(player.inventory_manager.right_hand_instance as GunControllerV2).selected_fire_mode
	)
	var has_more_than_one_fire_mode = (
		has_weapon and
		(player.inventory_manager.right_hand_instance as GunControllerV2).has_mode_than_one_fire_mode
	)
	visible = has_weapon
	mode_label.visible = has_more_than_one_fire_mode
	name_label.text = (
		(player.inventory_manager.right_hand_instance as GunControllerV2).item_name
		if has_weapon
		else ""
	)
	mode_label.text = (
		(player.inventory_manager.right_hand_instance as GunControllerV2).selected_fire_mode.mode_name
		if has_weapon
		else ""
	)
