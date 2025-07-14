extends Control

@onready var name_label: Label = $Label
@onready var fuel_bar: ColorRect = $FuelBar
@onready var fuel_bar_shadow: ColorRect = $FuelBarShadow

func _process(_delta: float) -> void:
	var player: Player = GameManager.get_player_one()
	if !player or player == null:
		visible = false
		return
	visible = player.inventory_manager.has_energy_gun
	if visible:
		var item_name = player.inventory_manager.right_hand_item_name
		name_label.text = item_name
		var fuel = GameManager.get_player_one().inventory_manager.energy / 100.0
		fuel_bar.material.set_shader_parameter("Progress", fuel)
		update_shadow(fuel)

func update_shadow(fuel: float):
	var current_progress = fuel_bar_shadow.material.get_shader_parameter("Progress")
	var lerp_fuel = lerpf(current_progress, fuel, 0.05)
	fuel_bar_shadow.material.set_shader_parameter("Progress", lerp_fuel)
