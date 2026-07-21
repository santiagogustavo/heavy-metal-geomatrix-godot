shader_type canvas_item;

uniform sampler2D SCREEN : hint_screen_texture;

void fragment() {
	vec4 base = texture(SCREEN, SCREEN_UV);
	vec4 blend = texture(TEXTURE, UV);
	vec4 limit = step(0.5, blend);
	COLOR = mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}
