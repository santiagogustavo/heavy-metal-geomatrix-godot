extends Control

@onready var label = $Label

func _process(_delta):
	var player: Player = GameManager.get_player_one()
	if !player or player == null:
		visible = false
		return
	visible = player.inventory_manager.has_melee
	if visible:
		label.text = player.inventory_manager.right_hand_item_name
