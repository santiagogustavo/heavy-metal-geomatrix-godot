extends Control
class_name VersusCard

@export var player: Player
@export var player_name: String
@export var avatar: Texture2D

@onready var label: Label = $Name
@onready var rect: TextureRect = $Avatar
@onready var health_bar: ColorRect = $HealthBar
@onready var health_bar_shadow: ColorRect = $HealthBarShadow

func _ready() -> void:
	if player_name:
		label.text = player_name
	if avatar:
		rect.texture = avatar

func _process(_delta: float) -> void:
	if !player:
		return
	var health_percentage = 1 - player.health / 100.0
	health_bar.material.set_shader_parameter("Progress", health_percentage)
	update_shadow(health_percentage)

func update_shadow(health_percentage: float) -> void:
	var current_progress = health_bar_shadow.material.get_shader_parameter("Progress")
	var lerp_health = lerpf(current_progress, health_percentage, 0.05)
	health_bar_shadow.material.set_shader_parameter("Progress", lerp_health)
