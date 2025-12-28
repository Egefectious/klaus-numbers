shader_type canvas_item;

// Creates a subtle repeating texture pattern like the HTML version
uniform float opacity : hint_range(0.0, 1.0) = 0.3;
uniform float scale : hint_range(0.1, 10.0) = 2.0;

void fragment() {
    vec2 uv = UV * scale * 100.0;
    
    // Create a subtle grid pattern
    float grid_x = step(0.5, fract(uv.x));
    float grid_y = step(0.5, fract(uv.y));
    float pattern = (grid_x * grid_y) * 0.05;
    
    COLOR = vec4(0.0, 0.0, 0.0, pattern * opacity);
}
