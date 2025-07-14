shader_type canvas_item;
render_mode unshaded;

uniform float fill_amount : hint_range(0.0, 1.0) = 0.5;
uniform float mask_rotation : hint_range(-360.0, 360.0, 0.1) = 0;
uniform vec2 mask_offset = vec2(0, 0);
uniform vec2 mask_size = vec2(1, 1);
uniform vec2 mask_rotation_pivot = vec2(0.5, 0.5);
uniform vec2 mask_scale_pivot = vec2(0.5, 0.5);

uniform bool invert_mask = false;
uniform bool use_different_texture = false;
uniform sampler2D mask_texture : filter_nearest;

vec2 rotate_degrees(vec2 uv, vec2 pivot, float deg){
	float rad = radians(deg + 90.0);
	mat2 rotation = mat2(vec2(sin(rad), -cos(rad)),vec2(cos(rad), sin(rad)));

	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

vec2 scale(vec2 uv, vec2 pivot, vec2 scale){
	uv -= pivot;
	uv = uv / scale;
	uv += pivot;
	return uv;
}

void fragment(){
	vec2 uv_rotated = rotate_degrees(UV, mask_rotation_pivot, mask_rotation);
	vec2 uv_position = scale(uv_rotated, mask_scale_pivot, mask_size * (1.0 - fill_amount)) + mask_offset;

	float alpha_total = texture(TEXTURE, uv_position).a;

	if (use_different_texture)
		alpha_total = texture(mask_texture, uv_position).a;

	bool is_within_bounds = uv_position.x >= 0.0 && uv_position.y >= 0.0 && uv_position.x <= 1.0 && uv_position.y <= 1.0;

	if (!invert_mask){
		if (is_within_bounds)
			COLOR.a -= alpha_total;
	}
	else{
		COLOR.a -= 1.0 - alpha_total;

		if (!is_within_bounds)
			COLOR.a = 0.0;
	}
}