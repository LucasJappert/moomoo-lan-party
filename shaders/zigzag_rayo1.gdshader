shader_type canvas_item;

uniform float amplitude = 3.0;
uniform float frequency = 20.0;
uniform float speed = 3.0;
uniform float randomness = 0.2;

// void fragment() {
//     // Copia de UV
//     vec2 uv = UV;

//     // Desplazamiento en Y según senoide
//     float wave = sin(uv.x * frequency + TIME * speed);
//     wave += sin(uv.x * frequency * 0.5 + TIME * speed * 1.5) * randomness;

//     // Aplica desplazamiento
//     uv.y += wave * amplitude * TEXTURE_PIXEL_SIZE.y;

//     // Aplica color
//     COLOR = texture(TEXTURE, uv) * COLOR;
// }

void fragment() {
    vec2 uv = UV;

    // Zigzag eléctrico
    float wave = sin(uv.x * frequency + TIME * speed);
    wave += sin(uv.x * frequency * 0.5 + TIME * speed * 1.5) * randomness;
    uv.y += wave * amplitude * TEXTURE_PIXEL_SIZE.y;

    // Flicker aleatorio (ruido determinista en UV + tiempo)
    float noise = fract(sin(dot(UV.xy * TIME * 100.0, vec2(12.9898,78.233))) * 43758.5453);
    float flicker = step(flicker_intensity, noise); // 0 o 1

    // Aplicar color si no fue descartado por flicker
    COLOR = texture(TEXTURE, uv) * COLOR * flicker;
}
