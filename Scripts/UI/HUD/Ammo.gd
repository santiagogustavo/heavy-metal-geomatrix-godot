extends Control

@onready var ammo_total_label: Label = $AmmoTotal
@onready var ammo_label: Label = $Ammo
@onready var name_label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _process(_delta):
	var player: Player = GameManager.get_player_one()
	if !player or player == null:
		visible = false
		return
	visible = player.inventory_manager.has_gun
	if visible:
		update_labels(player)
		play_shoot_animation(player)

func update_labels(player):
	var item_name = player.inventory_manager.right_hand_item_name
	var ammo_total = player.inventory_manager.ammo_total
	var ammo = player.inventory_manager.ammo
	ammo_total_label.text = '/' + ('0' if ammo_total < 10 else "") + str(ammo_total)
	ammo_label.text = ('0' if ammo < 10 else "") + str(ammo)
	name_label.text = item_name

func play_shoot_animation(player):
	if player.inventory_manager.is_gun_shooting:
		animation_player.stop(true)
		animation_player.play("Shoot")
