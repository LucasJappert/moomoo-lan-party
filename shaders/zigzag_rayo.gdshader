shader_type canvas_item;

uniform float amplitude = 3.0;
uniform float frequency = 20.0;
uniform float speed = 3.0;
uniform float randomness = 0.2;
uniform float flicker_intensity = 0.2;
uniform float glow_strength = 1.5;

void fragment() {
    vec2 uv = UV;

    // Zigzag eléctrico
    float wave = sin(uv.x * frequency + TIME * speed);
    wave += sin(uv.x * frequency * 0.5 + TIME * speed * 1.5) * randomness;
    uv.y += wave * amplitude * TEXTURE_PIXEL_SIZE.y;

    // Flicker aleatorio
    float noise = fract(sin(dot(UV.xy * TIME * 100.0, vec2(12.9898,78.233))) * 43758.5453);
    float flicker = step(flicker_intensity, noise);

    // Simular brillo con multiplicador según cercanía al centro
    float dist_to_center = distance(UV, vec2(0.5));
    float glow = pow(1.0 - dist_to_center, 2.0) * glow_strength;

    vec4 tex = texture(TEXTURE, uv);
    COLOR = tex * COLOR * flicker * (1.0 + glow);
}
