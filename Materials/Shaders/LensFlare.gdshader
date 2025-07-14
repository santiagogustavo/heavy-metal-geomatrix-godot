//////////////////////////////////////////////////////////////////
//by Marcel Klee - WuotanStudios - 2024
//used in project "RIAD - Reborn in a Dungeon"
//A first person - story driven - action game [WIP]
//
//For more infos follow me on:
//Twitter: https://x.com/WuotanStudios
//Bluesky: https://bsky.app/profile/wuotanstudios.bsky.social
//Striked: https://striked.gg/app/space/29-riad/news-about-riad
//www.wuotanstudios.com
//////////////////////////////////////////////////////////////////


shader_type canvas_item;

render_mode blend_add;

uniform lowp sampler2D Screen_Sample : hint_screen_texture, filter_linear_mipmap_anisotropic;
uniform lowp sampler2D FlareMult;
uniform lowp sampler2D FlareMult2;

uniform float Blur = 2.5;
uniform float FlareThreshold;
uniform float Thresholdsmoothness = 0.2;
uniform int Flares;
uniform float FlareSpacing;
uniform float FlareDistance = 0.5;
uniform float LensThickness = 1.0;

uniform float Intensity;
uniform float Saturation_;
uniform float visibility = 0.95;

uniform float MinFlareIntensity = 0.0;
uniform float MaxFlareIntensity = 0.22;

uniform float AberrationStrength = 0.012;
uniform float EmissionThreshold = 0.8;  // Emission Schwellenwert

// Funktion zur Anwendung des Thresholds
vec3 ApplyThreshold(vec3 color, float threshold){
	return color * smoothstep(threshold - Thresholdsmoothness, threshold + Thresholdsmoothness, length(color));
}

// Funktion zur Anpassung der Sättigung
vec3 AdjustSaturation(vec3 color, float saturation) {
	float gray = dot(color, vec3(0.299, 0.587, 0.114));
	return mix(vec3(gray), color, saturation);
}

// Funktion zur Berechnung der chromatischen Aberration
vec3 ChromaticAberration(vec2 uv, float strength) {
	vec2 offset = uv - vec2(0.5);
	float dist = length(offset);

	vec2 redUV = uv + offset * strength * dist;
	vec2 blueUV = uv - offset * strength * dist;

	vec3 red = texture(Screen_Sample, redUV).rgb;
	vec3 green = texture(Screen_Sample, uv).rgb;
	vec3 blue = texture(Screen_Sample, blueUV).rgb;

	return vec3(red.r, green.g, blue.b);
}

void fragment(){
	vec2 FlippedUV = vec2(LensThickness) - SCREEN_UV;
	vec2 FlareVector = (vec2(FlareDistance) - SCREEN_UV) * FlareSpacing;
	vec3 FinalFlare = vec3(0.0);

	for (int i = 0; i < Flares; ++i){
		vec2 SUV = fract(SCREEN_UV + FlareVector * vec2(float(i)));
		float Dist = distance(SUV, vec2(0.5));
		float Weight = 1.0 - smoothstep(0.0, 0.75, Dist);

		// Hole den Emission-Wert von der Textur (z.B. könnte das Screen_Sample den Emission-Wert enthalten)
		vec3 BlurredScreen = texture(Screen_Sample, SUV, Blur).rgb;

		// Überprüfen, ob der Emission-Wert den EmissionThreshold überschreitet
		float emission_value = length(BlurredScreen);  // Gesamthelligkeit
		if (emission_value > EmissionThreshold) {
			BlurredScreen = ApplyThreshold(BlurredScreen, FlareThreshold);
			FinalFlare += BlurredScreen * Weight;
		}
	}

	FinalFlare *= texture(FlareMult, SCREEN_UV).rgb;
	FinalFlare *= texture(FlareMult2, SCREEN_UV).rgb;
	FinalFlare *= Intensity;
	FinalFlare = clamp(FinalFlare, vec3(MinFlareIntensity), vec3(MaxFlareIntensity));

	// Sättigung anwenden
	FinalFlare = AdjustSaturation(FinalFlare, Saturation_);

	// Chromatische Aberration (Regenbogeneffekt)
	vec3 rainbowEffect = ChromaticAberration(SCREEN_UV, AberrationStrength);

	// Kombiniere den FinalFlare mit dem Regenbogeneffekt
	FinalFlare = mix(FinalFlare, rainbowEffect, 0.5);

	COLOR.rgb = FinalFlare;
	COLOR.a = visibility;
}
