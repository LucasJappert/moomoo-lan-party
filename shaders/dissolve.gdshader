shader_type canvas_item;

uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D noise_texture : hint_default_white;
uniform float noise_scale : hint_range(1.0, 20.0) = 5.0; // noise texture scale

void fragment() {
	vec2 scaled_uv = UV * noise_scale; // scale the noise
	vec4 tex = texture(TEXTURE, UV);
	vec4 noise = texture(noise_texture, scaled_uv); // use the scaled UVs

	if (noise.r < dissolve_amount) {
		discard;
	}
	// COLOR = tex * vertex_color;
	COLOR = tex;
}
