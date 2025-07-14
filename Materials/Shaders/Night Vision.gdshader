shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;

uniform vec3 luminance: source_color = vec3(0.3, 0.6, 0.08);
uniform vec3 base_color: source_color = vec3(0.2, 1.0, 0.4);
uniform float brightness: hint_range(0.0, 10.0, 0.01) = 2.0;
uniform float noise_level: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float vignette_level: hint_range(0.0, 1.0, 0.01) = 0.4;
uniform float edge_x: hint_range(0.0, 5.0, 0.01) = 1.0;
uniform float edge_y: hint_range(0.0, 5.0, 0.01) = 1.0;
uniform float flickering_level: hint_range(0.0, 1.0, 0.01) = 0.1;

float hash11(float x) {
	return fract(cos(mod(dot(vec2(x,x), vec2(13.9898, 8.141)), 3.14)) * 43758.5453);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV - 0.5;
	vec2 resolution = 1.0 / TEXTURE_PIXEL_SIZE;
	uv.x *= resolution.x / resolution.y;
	float time = TIME;
	vec3 color = texture(screen_texture, SCREEN_UV).rgb;
	float grain = hash11(uv.x) + uv.y;
	color += hash11(grain * time) * noise_level;
	vec2 edge = uv * uv * uv * vec2(edge_x, edge_y);
	color *= smoothstep(length(edge), 1.0, vignette_level);
	vec3 flicker = vec3(0.0, hash11(time) * flickering_level, 0.0);
	vec3 vision_color = base_color * flicker;
	color = dot(color, luminance) * base_color;
	COLOR = vec4(color * brightness, 1.0);
}
