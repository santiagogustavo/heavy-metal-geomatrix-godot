extends Control

@onready var animation_tree: AnimationTree = $AnimationTree

var is_shooting: bool = false

func _ready() -> void:
	var player_one: Player = GameManager.get_player_one()
	if player_one:
		player_one.inventory_manager.gun_shoot.connect(func ():
			(animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback).travel("Shoot", true)
			animation_tree.set("parameters/Shoot/TimeSeek/seek_request", 0.0)
		)
