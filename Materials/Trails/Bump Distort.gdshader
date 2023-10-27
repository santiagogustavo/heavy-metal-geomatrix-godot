shader_type spatial;

//#define GPU_TRAIL
//#include "res://addons/GPUTrail/shaders/gputrail_lib.gdshaderinc"

render_mode unshaded,world_vertex_coords,cull_disabled;

uniform sampler2D tex : repeat_disable, source_color, hint_default_white;
uniform sampler2D color_ramp : repeat_disable, source_color, hint_default_white;
uniform sampler2D curve : repeat_disable, hint_default_white;
uniform mat4 emmission_transform = mat4(1);
uniform int flags = 0;
/*uniform bool vertical_texture = false;
uniform bool use_red_as_alpha = false;
uniform bool billboard = false;
uniform bool dewiggle = false;
uniform bool snap_to_transform = false;*/

#define vertical_texture  bool(flags & 1)
#define use_red_as_alpha  bool(flags & 2)
#define billboard		  bool(flags & 4)
#define dewiggle 		  bool(flags & 8)
#define snap_to_transform bool(flags & 16)
#define clip_overlaps bool(flags & 32)

varying float scale_interp;
varying vec2 clip;
varying vec2 mesh_uv;
void vertex(){
	mesh_uv = UV;
	
	mat4 my_model_matrix = MODEL_MATRIX;
	if(snap_to_transform && INSTANCE_CUSTOM.w==2.0){
		my_model_matrix[1] = emmission_transform * vec4(0,1,0,1);
		my_model_matrix[2] = emmission_transform * vec4(0,-1,0,1);
	}
	
	if(billboard){
		vec3 t0 = my_model_matrix[0].xyz-my_model_matrix[3].xyz;
		vec3 t1 = my_model_matrix[1].xyz-my_model_matrix[2].xyz;
		
		//vec3 up1 = up0;
		vec3 up0 = length(t0)*normalize(
			cross(
				my_model_matrix[3].xyz-INV_VIEW_MATRIX[3].xyz,
				//-INV_VIEW_MATRIX[2].xyz,
				t0));
		vec3 up1 = length(t1)*normalize(
			cross(
				my_model_matrix[2].xyz-INV_VIEW_MATRIX[3].xyz,
				//-INV_VIEW_MATRIX[2].xyz,
				t1));
		
		my_model_matrix[0] = my_model_matrix[3];
		my_model_matrix[1] = my_model_matrix[2];
		
		my_model_matrix[0].xyz += up0;
		my_model_matrix[3].xyz -= up0;
		
		my_model_matrix[1].xyz += up1;
		my_model_matrix[2].xyz -= up1;
	}
	
	vec3 a = mix(my_model_matrix[1].xyz,my_model_matrix[0].xyz,UV.x);
	vec3 b = mix(my_model_matrix[2].xyz,my_model_matrix[3].xyz,UV.x);

	UV.x = (UV.x + INSTANCE_CUSTOM.w-1.0 - 2.0)/(INSTANCE_CUSTOM.z-1.0);

	
	float h = textureLod(curve, vec2(UV.x), 0.0).x;//h=1.0;
	
	VERTEX = mix(a,b,(UV.y-0.5)*h + 0.5);

	if(dewiggle){
		scale_interp = h;
		UV *= scale_interp;
	}
	
		
	clip.x = dot(VERTEX - INV_VIEW_MATRIX[3].xyz,cross(my_model_matrix[1].xyz - INV_VIEW_MATRIX[3].xyz,my_model_matrix[2].xyz - INV_VIEW_MATRIX[3].xyz));
	clip.y = dot(VERTEX - INV_VIEW_MATRIX[3].xyz,cross(my_model_matrix[3].xyz - INV_VIEW_MATRIX[3].xyz,my_model_matrix[0].xyz - INV_VIEW_MATRIX[3].xyz));
}

uniform float distortion_size = 0.4;
uniform sampler2D normal_map;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment(){
	//PREPARE_TRAIL_TEXTURES();
	
	vec2 d = texture(normal_map, UV).xy - vec2(0.5);
	ALBEDO = texture(SCREEN_TEXTURE, SCREEN_UV + d * distortion_size).rgb;
}