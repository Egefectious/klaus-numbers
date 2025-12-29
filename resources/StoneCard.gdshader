shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.15, 0.15, 0.18, 1.0);
uniform vec4 glow_color : source_color = vec4(0.3, 0.85, 1.0, 1.0);
uniform float active_state : hint_range(0.0, 1.0) = 0.0; // 0 = inactive, 1 = active

// Simple noise function
float random (vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
    // 1. Generate Stone Noise
    float noise = random(UV * 100.0); // High frequency noise
    vec4 stone = base_color + vec4(noise * 0.05); // Add subtle grit

    // 2. Inner Shadow / Bevel
    float dist = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
    float edge = smoothstep(0.0, 0.1, dist);
    stone.rgb *= (0.5 + 0.5 * edge); // Darken edges

    // 3. Apply Glow (if active)
    vec4 glow = glow_color * (1.0 - edge) * active_state * 0.8;

    COLOR = stone + glow;
}