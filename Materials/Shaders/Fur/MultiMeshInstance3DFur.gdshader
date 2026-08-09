shader_type spatial;
// MultiMesh Shell Texturing shader by HaruYou27
uniform sampler2D noise : filter_linear_mipmap;
uniform float layers = 17;
uniform float hash_scale : hint_range(0.0, 2.0) = 0.5; // Too high will make the fur blocky, too low and it will flickering.
uniform float shell_length = 0.005;
uniform float SpreadPow = 1.1;
uniform vec3 color : source_color = vec3(1.0);
uniform float roughness : hint_range(0.0, 1.0) = 0.8;

instance uniform int layer = 1;

varying flat float height;

void vertex() {
	height = float(INSTANCE_ID + layer) / layers;

	// Vertex code from:
	// https://godotshaders.com/shader/fur-grass-with-shell-texturing/
	float h = pow(height, SpreadPow);
	//what is happening here -> we don't want to linearly spread our meshes.
	//so, we take their pow. if spread pow > 1 -> numbers smaller than one decrease
	//thus the closer you get to the outer most layer, the further away from 1 you get,
	//thus the greater the dist betwixt layers become. and vice versa if spread pow < 1

	VERTEX = fma(NORMAL, vec3(h * shell_length), VERTEX);
}

void fragment() {
	float noise_value = texture(noise, UV).r;
	ALPHA = fma(1.5, noise_value, -height); // Avoid negative alpha value.
	ALPHA_HASH_SCALE = hash_scale;
	
	ALBEDO = color;
	ROUGHNESS = roughness;
	AO = height;
}
