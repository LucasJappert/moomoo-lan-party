shader_type canvas_item;

uniform float strength : hint_range(0.0, 1.0) = 1.0;
uniform float green_threshold : hint_range(0.0, 1.0) = 0.05;

varying vec4 vtx_color;

void vertex() {
    vtx_color = COLOR; // captura el modulate del Sprite2D
}

void fragment() {
    vec4 c = texture(TEXTURE, UV) * vtx_color;
    float dom = c.g - max(c.r, c.b);
    if (dom > green_threshold) {
        float g = c.g;
        c.r = mix(c.r, g, strength);
        c.g = mix(c.g, 0.0, strength);
    }
    COLOR = c;
}
