extends Control

@onready var name_label: Label = $PlayerName
@onready var health_bar: ColorRect = $HealthBar

func _process(_delta: float) -> void:
	var player: Player = GameManager.get_player_one()
	if !player or player == null:
		visible = false
		return
	visible = true
	name_label.text = player.player_name
	var health_percentage = player.health / 100.0
	health_bar.material.set_shader_parameter("Progress", health_percentage)
