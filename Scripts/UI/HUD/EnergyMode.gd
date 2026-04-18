extends Control

@onready var fuel_bar: ColorRect = $FuelBar
@onready var fuel_bar_shadow: ColorRect = $FuelBarShadow

func _process(_delta: float) -> void:
	var player: Player = GameManager.get_player_one()
	var has_player = player and player != null
	var energy_mode_selected = (
		has_player and
		player.inventory_manager.has_energy_gun
	)
	visible = energy_mode_selected
	if visible:
		var fuel = GameManager.get_player_one().inventory_manager.energy / 100.0
		fuel_bar.material.set_shader_parameter("Progress", fuel)
		update_shadow(fuel)

func update_shadow(fuel: float):
	var current_progress = fuel_bar_shadow.material.get_shader_parameter("Progress")
	var lerp_fuel = lerpf(current_progress, fuel, 0.05)
	fuel_bar_shadow.material.set_shader_parameter("Progress", lerp_fuel)
