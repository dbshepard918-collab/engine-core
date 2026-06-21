shader_type spatial;
render_mode blend_add, unshaded, cull_disabled;
uniform vec4 base_color : source_color = vec4(0.0, 0.9, 1.0, 1.0);
uniform float scanline_density = 80.0;
uniform float scanline_speed = 2.0;
uniform float fresnel_power = 3.0;
uniform float glitch_strength = 0.03;
void fragment() {
    float scan = sin((UV.y * scanline_density) + TIME * scanline_speed) * 0.5 + 0.5;
    float fresnel = pow(1.0 - dot(NORMAL, VIEW), fresnel_power);
    float glitch = step(0.98, fract(sin(floor(UV.y * 20.0) * 43758.5453 + TIME) * 143.13));
    ALBEDO = base_color.rgb;
    ALPHA = clamp(0.25 + scan * 0.35 + fresnel + glitch * glitch_strength, 0.0, 1.0);
    EMISSION = base_color.rgb * (1.5 + scan * 2.0 + fresnel * 3.0);
}
