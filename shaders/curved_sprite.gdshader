shader_type canvas_item;

uniform float curve_amount = 0.0;

void vertex() {
    float center_x = 0.0;
    float dist = VERTEX.x - center_x;
    VERTEX.y += -pow(dist, 2.0) * curve_amount;
}
