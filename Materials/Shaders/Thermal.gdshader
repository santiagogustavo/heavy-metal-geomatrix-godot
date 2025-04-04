shader_type canvas_item;

/* GradientTexture1D for luminance mapping */
uniform sampler2D gradient;

/* Optional snippet for using screen instead of TextureRect */
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;
uniform bool use_screen_texture = false;
uniform bool use_screen_uv = true;

void fragment() {
	vec2 uv;
	vec4 color;
	vec4 original_color = COLOR;
	if (use_screen_uv) {
		uv = SCREEN_UV;
	} else {
		uv = UV;
	}
	if (use_screen_texture) {
		color = texture(SCREEN_TEXTURE, uv);
	} else {
		color = texture(TEXTURE, uv);
	}

	/* RGB influence over luminance */
	/* https://en.wikipedia.org/wiki/Relative_luminance */
	float r = 0.2126 * color.r;
	float g = 0.7152 * color.g;
	float b = 0.0722 * color.b;
	float luminance = r + g + b;
	vec4 grad = texture(gradient, vec2(luminance, 0.0));
	COLOR = vec4(grad.rgb, color.a * original_color.a);
}
