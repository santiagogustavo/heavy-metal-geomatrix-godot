shader_type spatial;

render_mode unshaded, particle_trails, cull_disabled;

uniform float distortion_size = 0.4;
uniform sampler2D mask;
uniform sampler2D normal_map;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 d = texture(normal_map, UV).xy - vec2(0.5);
	ALBEDO = texture(SCREEN_TEXTURE, SCREEN_UV + d * distortion_size).rgb;
	ALPHA = COLOR[3] * texture(mask, UV).a;
}
