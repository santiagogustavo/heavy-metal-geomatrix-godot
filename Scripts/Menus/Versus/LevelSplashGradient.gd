extends ColorRect
class_name LevelSplashGradient

@export var texture: Texture2D

func _ready() -> void:
	update_material_gradient(texture)

func update_material_gradient(splash: Texture2D) -> void:
	if !splash:
		return
	var average_color: Color = get_average_color(splash)
	var gradient_texture: GradientTexture1D = GradientTexture1D.new()
	gradient_texture.gradient = Gradient.new()
	gradient_texture.gradient.set_color(0.0, Color.BLACK)
	gradient_texture.gradient.set_color(1.0, average_color)
	material.set("shader_parameter/gradient", gradient_texture)

func get_average_color(splash: Texture2D) -> Color:
	var image: Image = splash.get_image()
	image.decompress()
	var all_colors: Vector3 = Vector3(0, 0, 0)
	var total_pixels: int = image.get_size()[0] + image.get_size()[1]
	for y in range(0, image.get_size().y):
		for x in range(0, image.get_size().x):
			var pixel: Color = image.get_pixel(x, y)
			all_colors += Vector3(pixel.r, pixel.g, pixel.b) / 255.0
	all_colors /= total_pixels
	return Color(all_colors[0], all_colors[1], all_colors[2])
