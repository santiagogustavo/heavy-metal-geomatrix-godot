extends Control

@onready var ammo_total_label: Label = $AmmoTotal
@onready var ammo_label: Label = $Ammo
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var has_connected_shoot: bool = false

func _process(_delta):
	var player = GameManager.get_player_one()
	if player:
		visible = player.inventory_manager.has_gun
		if visible:
			update_labels(player)
			if player.input_manager and !has_connected_shoot:
				player.input_manager.connect("shoot", play_shoot_animation)
				has_connected_shoot = true
	else:
		visible = false

func update_labels(player):
	var ammo_total = player.inventory_manager.ammo_total
	var ammo = player.inventory_manager.ammo
	ammo_total_label.text = ('0' if ammo_total < 10 else "") + str(ammo_total)
	ammo_label.text = ('0' if ammo < 10 else "") + str(ammo)

func play_shoot_animation():
	animation_player.stop(true)
	animation_player.play("Shoot")
