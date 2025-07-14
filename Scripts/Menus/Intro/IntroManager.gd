extends Control

@export_file var redirect_to_scene: String
@onready var animation_player = $AnimationPlayer

func _init():
	GameManager.current_scene_type = Definitions.SceneType.Intro

func _ready():
	animation_player.current_animation = 'FadeInGodot'
	await get_tree().create_timer(3).timeout

	animation_player.current_animation = 'FadeOutGodot'
	await get_tree().create_timer(0.3).timeout
	
	animation_player.current_animation = 'FadeInCapcom'
	await get_tree().create_timer(2).timeout
	
	animation_player.current_animation = 'FadeOutCapcom'
	await get_tree().create_timer(0.3).timeout
	
	animation_player.current_animation = 'FadeInSantiago'
	await get_tree().create_timer(2).timeout
	
	animation_player.current_animation = 'FadeOutSantiago'
	await get_tree().create_timer(0.5).timeout

	get_tree().change_scene_to_file(redirect_to_scene)
