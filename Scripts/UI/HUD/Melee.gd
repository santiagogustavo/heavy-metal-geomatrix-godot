extends Control

@onready var condition_bar = $ConditionBar

func _process(delta):
	if GameManager.get_player_one():
		visible = GameManager.get_player_one().inventory_manager.has_melee
		if visible:
			var health = GameManager.get_player_one().inventory_manager.melee_health / 100
			condition_bar.material.set_shader_parameter("Progress", health)
	else:
		visible = false
