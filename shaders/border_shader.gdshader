shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform float outline_width : hint_range(0.0, 10.0) = 0.5;
uniform float outline_threshold : hint_range(0.0, 1.0) = 0.7; // sensibilidad para detectar los bordes del sprite
uniform vec2 frame_size = vec2(64.0, 64.0); 
uniform vec2 frame_offset = vec2(0.0); 

void fragment() {
    vec2 pixel_size = TEXTURE_PIXEL_SIZE * outline_width;
    vec4 tex_color = texture(TEXTURE, UV);
    vec4 final_color = tex_color; // Color por defecto
    
    // Calcula coordenadas relativas al frame actual
    vec2 frame_uv = UV - frame_offset;
    frame_uv = mod(frame_uv, frame_size * TEXTURE_PIXEL_SIZE);
    
    // Verifica si el píxel está dentro del frame actual
    if (frame_uv.x >= 0.0 && frame_uv.y >= 0.0 && 
        frame_uv.x <= frame_size.x * TEXTURE_PIXEL_SIZE.x && 
        frame_uv.y <= frame_size.y * TEXTURE_PIXEL_SIZE.y) {
        
        // Busca píxeles opacos alrededor (para el borde)
        float max_alpha = 0.0;
        for (float angle = 0.0; angle < 6.283; angle += 0.628) {
            vec2 offset = vec2(cos(angle), sin(angle)) * pixel_size;
            vec2 sample_uv = UV + offset;
            vec2 sample_frame_uv = mod(sample_uv - frame_offset, frame_size * TEXTURE_PIXEL_SIZE);
            
            if (sample_frame_uv.x >= 0.0 && sample_frame_uv.y >= 0.0 && 
                sample_frame_uv.x <= frame_size.x * TEXTURE_PIXEL_SIZE.x && 
                sample_frame_uv.y <= frame_size.y * TEXTURE_PIXEL_SIZE.y) {
                max_alpha = max(max_alpha, texture(TEXTURE, sample_uv).a);
            }
        }
        
        // Aplica el borde si cumple las condiciones
        if (tex_color.a < outline_threshold && max_alpha > outline_threshold) {
            final_color = outline_color;
        }
    }
    
    COLOR = final_color; // Asigna el color final (sin usar 'return')
}