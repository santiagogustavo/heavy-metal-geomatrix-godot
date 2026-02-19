extends Control

@onready var color_rect: ColorRect = $ColorRect
@onready var label: Label = $ColorRect/MarginContainer/Label
@onready var animation_tree: AnimationTree = $AnimationTree

var pickup_collided: bool = false
var pickup_leave: bool = true

func _ready() -> void:
	var player: Player = GameManager.get_player_one()
	if player:
		player.pickup_collided.connect(func (pickup: Pickup):
			pickup_collided = true
			pickup_leave = false
			label.text = pickup.item_name
			color_rect.color = Definitions.PickupColorHashes[pickup.pickup_color]
		)
		player.pickup_leave.connect(func ():
			pickup_collided = false
			pickup_leave = true
		)

func _process(_delta: float) -> void:
	animation_tree.set("parameters/conditions/pickup_collided", pickup_collided)
	animation_tree.set("parameters/conditions/pickup_leave", pickup_leave)
