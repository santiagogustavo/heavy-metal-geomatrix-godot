extends Control

@onready var name_label: Label = $PlayerName
@onready var avatar_image: TextureRect = $Avatar
@onready var health_bar: ColorRect = $HealthBar
@onready var health_bar_shadow: ColorRect = $HealthBarShadow

func _process(_delta: float) -> void:
	var player: Player = GameManager.get_player_one()
	if !player or player == null:
		visible = false
		return
	visible = true
	name_label.text = player.player_name
	avatar_image.texture = player.character.avatar_big
	var health_percentage: float = player.health / 100.0
	health_bar.material.set_shader_parameter("Progress", health_percentage)
	update_shadow(health_percentage)

func update_shadow(health_percentage: float) -> void:
	var current_progress = health_bar_shadow.material.get_shader_parameter("Progress")
	var lerp_health = lerpf(current_progress, health_percentage, 0.05)
	health_bar_shadow.material.set_shader_parameter("Progress", lerp_health)
