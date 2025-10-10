extends MeshInstance3D
class_name AnimatedTexturesMesh

@export var face_surface: int

@export_subgroup("Masks")
@export var blink_mask: Texture2D
@export var talk_masks: Array[Texture2D]
@export var hurt_eye_mask: Texture2D
@export var hurt_mouth_mask: Texture2D
@export var die_mouth_mask: Texture2D

@export_subgroup("Control")
@export var is_talking: bool
@export var is_hurt: bool
@export var is_dead: bool

var face_surface_material: StandardMaterial3D
var base_face_texture: Texture2D

var tex_buffer: Image

var timers: Dictionary = {}

var blank_image: Image
var current_talk_image: Image
@onready var blink_image: Image = convert_texture2d_to_decompressed_image(blink_mask)
@onready var talk_images: Array = talk_masks.map(convert_texture2d_to_decompressed_image)
@onready var hurt_eye_image: Image = convert_texture2d_to_decompressed_image(hurt_eye_mask)
@onready var hurt_mouth_image: Image = convert_texture2d_to_decompressed_image(hurt_mouth_mask)
@onready var die_mouth_image: Image = convert_texture2d_to_decompressed_image(die_mouth_mask)

func convert_texture2d_to_decompressed_image(tex: Texture2D):
	var image: Image = tex.get_image()
	image.decompress()
	return image

func create_timer(timer_name: String):
	timers[timer_name] = Timer.new()
	timers[timer_name].timeout.connect(func (): timers[timer_name].stop())
	add_child(timers[timer_name])

func _ready() -> void:
	face_surface_material = get_surface_override_material(face_surface)
	face_surface_material.detail_enabled = true
	base_face_texture = face_surface_material.albedo_texture
	blank_image = Image.create_empty(
		base_face_texture.get_width(),
		base_face_texture.get_height(),
		false,
		Image.FORMAT_DXT5
	)
	blank_image.decompress()
	create_timer("blink_timer")
	create_timer("blink_delay")
	create_timer("talk_timer")

func _process(_delta: float) -> void:
	tex_buffer = blank_image.duplicate()
	if is_dead:
		dead_texture()
	elif is_hurt:
		hurt_texture()
	else:
		if !timers["blink_timer"].is_stopped():
			blink_texture()
		if !timers["talk_timer"].is_stopped() and is_talking:
			talk_texture()
	face_surface_material.detail_albedo = ImageTexture.create_from_image(tex_buffer)
	compute_blink()
	compute_talk()

func hurt_texture() -> void:
	tex_buffer.blend_rect(
		hurt_eye_image,
		hurt_eye_image.get_used_rect(),
		hurt_eye_image.get_used_rect().position
	)
	tex_buffer.blend_rect(
		hurt_mouth_image,
		hurt_mouth_image.get_used_rect(),
		hurt_mouth_image.get_used_rect().position
	)

func dead_texture() -> void:
	tex_buffer.blend_rect(
		hurt_eye_image,
		hurt_eye_image.get_used_rect(),
		hurt_eye_image.get_used_rect().position
	)
	tex_buffer.blend_rect(
		die_mouth_image,
		die_mouth_image.get_used_rect(),
		die_mouth_image.get_used_rect().position
	)

func blink_texture() -> void:
	tex_buffer.blend_rect(
		blink_image,
		blink_image.get_used_rect(),
		blink_image.get_used_rect().position
	)

func compute_blink() -> void:
	if !timers["blink_delay"].is_stopped():
		return
	var time_to_open: float = randf_range(0.05, 0.1)
	var time_to_next: float = randf_range(0.25, 0.75)
	timers["blink_timer"].start(time_to_open)
	timers["blink_delay"].start(time_to_next)

func compute_talk() -> void:
	if !timers["talk_timer"].is_stopped() or !is_talking:
		return
	var time_to_next: float = randf_range(0.075, 0.15)
	var next_mouth: Image = null
	while !next_mouth or next_mouth == current_talk_image:
		next_mouth = talk_images.pick_random()
	current_talk_image = next_mouth
	timers["talk_timer"].start(time_to_next)

func talk_texture() -> void:
	tex_buffer.blend_rect(
		current_talk_image,
		current_talk_image.get_used_rect(),
		current_talk_image.get_used_rect().position
	)
