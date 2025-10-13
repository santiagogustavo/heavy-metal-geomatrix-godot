extends Node3D

@onready var splatter_1: GPUParticles2D = $Control/Splatter1
@onready var splatter_2: GPUParticles2D = $Control/Splatter2

func _ready() -> void:
	var player: Player = GameManager.get_player_one()
	if !player:
		return
	player.player_damage.connect(func ():
		if !splatter_1.emitting:
			splatter_1.restart()
			splatter_1.emitting = true
		if !splatter_2.emitting:
			splatter_2.restart()
			splatter_2.emitting = true
	)
