extends Control

@onready var ammo_total_label: Label = $AmmoTotal
@onready var ammo_label: Label = $Ammo

func _process(delta):
	var player = GameManager.get_player_one()
	if player:
		visible = player.inventory_manager.has_gun
		if visible:
			var ammo_total = player.inventory_manager.ammo_total
			var ammo = player.inventory_manager.ammo
			ammo_total_label.text = ('0' if ammo_total < 10 else "") + str(ammo_total)
			ammo_label.text = ('0' if ammo < 10 else "") + str(ammo)
	else:
		visible = false
