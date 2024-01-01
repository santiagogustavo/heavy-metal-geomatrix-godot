extends Control

@onready var fuel_bar = $FuelBar

func _process(delta):
	if GameManager.get_player_one():
		visible = GameManager.get_player_one().inventory_manager.has_jetpack
		if visible:
			var fuel = GameManager.get_player_one().inventory_manager.jetpack_fuel / 100
			fuel_bar.material.set_shader_parameter("Progress", fuel)
	else:
		visible = false
