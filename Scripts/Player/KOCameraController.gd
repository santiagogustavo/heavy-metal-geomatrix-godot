extends Marker3D
class_name KOCameraController

@onready var camera: Camera3D = $Camera3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var active_camera: Camera3D

func _ready() -> void:
	active_camera = get_viewport().get_camera_3d()

func play_ko_animation() -> void:
	camera.make_current()
	animation_player.play("KO")
