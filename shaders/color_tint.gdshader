shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // Tint applied over the original color
    vec3 tinted_rgb = mix(tex_color.rgb, tint_color.rgb, tint_strength);

    // Keep original alpha
    float final_alpha = tex_color.a;

    COLOR = vec4(tinted_rgb, final_alpha);
}
