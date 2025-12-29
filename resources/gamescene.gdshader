shader_type canvas_item;
void fragment() {
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(UV, center);
    // Dark blueish-black radial gradient
    vec4 col = mix(vec4(0.08, 0.08, 0.15, 1.0), vec4(0.02, 0.02, 0.05, 1.0), dist * 1.5);
    COLOR = col;
}