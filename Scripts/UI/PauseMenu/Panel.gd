extends Node

@onready var animator = $AnimationPlayer

var has_played_animation = false

func _process(_delta):
	if GameManager.is_game_paused and !has_played_animation:
		animator.play("Open")
		has_played_animation = true
	elif !GameManager.is_game_paused:
		has_played_animation = false
		animator.play("Reset")
