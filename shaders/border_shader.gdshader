shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 1.0, 0.0, 1.0); // Verde
uniform float outline_width : hint_range(0.0, 10.0) = 1.0; // 5 píxeles de ancho
uniform float outline_threshold : hint_range(0.0, 1.0) = 0.5; // Ajusta para suavizar

void fragment() {
    vec2 pixel_size = TEXTURE_PIXEL_SIZE * outline_width;
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Detección del borde: muestrea en un círculo alrededor del píxel actual
    float max_alpha = 0.0;
	for (float angle = 0.0; angle < 6.283; angle += 1.0) { // Menos preciso pero más rápido
    // for (float angle = 0.0; angle < 6.283; angle += 0.628) { // Muestrea 10 puntos
        vec2 offset = vec2(cos(angle), sin(angle)) * pixel_size;
        max_alpha = max(max_alpha, texture(TEXTURE, UV + offset).a);
    }
    
    // Si el píxel actual es transparente pero hay opacidad cerca, dibuja el borde
    if (tex_color.a < outline_threshold && max_alpha > outline_threshold) {
        COLOR = outline_color;
    } else {
        COLOR = tex_color;
    }
}