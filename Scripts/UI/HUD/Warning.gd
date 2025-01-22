extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var decoration: TextureRect = $Decoration
@onready var glitch: TextureRect = $Glitch

var has_played_animation: bool = false

func _process(_delta: float) -> void:
	var player: Player = GameManager.get_player_one()
	if !player or player == null:
		visible = false
		return
	visible = true
	update_glitch(player.health)
	if player.health <= 20 and !has_played_animation:
		decoration.visible = true
		has_played_animation = true
		animation_player.play("Idle")
	elif player.health > 20:
		decoration.visible = false
		has_played_animation = false

func update_glitch(health: int) -> void:
	var glitch_progress: float = 1.0 - (health / 35.0)
	glitch.self_modulate.a = glitch_progress
