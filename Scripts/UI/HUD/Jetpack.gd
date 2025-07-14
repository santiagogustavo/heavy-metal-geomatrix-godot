extends Control

@onready var fuel_bar = $FuelBar
@onready var fuel_bar_shadow = $FuelBarShadow

func _process(_delta):
	var player: Player = GameManager.get_player_one()
	if !player or player == null:
		visible = false
		return
	visible = player.inventory_manager.has_jetpack
	if visible:
		var fuel = GameManager.get_player_one().inventory_manager.jetpack_fuel / 100
		fuel_bar.material.set_shader_parameter("Progress", fuel)
		update_shadow(fuel)

func update_shadow(fuel):
	var current_progress = fuel_bar_shadow.material.get_shader_parameter("Progress")
	var lerp_fuel = lerpf(current_progress, fuel, 0.05)
	fuel_bar_shadow.material.set_shader_parameter("Progress", lerp_fuel)
