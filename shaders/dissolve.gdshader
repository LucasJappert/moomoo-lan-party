shader_type canvas_item;
render_mode blend_mix;

uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D noise_texture : hint_default_white;
uniform float noise_scale : hint_range(1.0, 20.0) = 5.0;
uniform vec2 noise_offset = vec2(0.0);

varying vec4 vertex_color;

void vertex() {
    vertex_color = COLOR;
}

void fragment() {
    // Evita clamp a borde y “wipes” si el import no tiene Repeat
    vec2 tiled_uv = fract(UV * noise_scale + noise_offset);
    float noise_value = texture(noise_texture, tiled_uv).r;

    if (noise_value < dissolve_amount) {
        discard;
    }

    vec4 tex = texture(TEXTURE, UV);
    COLOR = vec4(tex.rgb * vertex_color.rgb, tex.a * vertex_color.a);
}
