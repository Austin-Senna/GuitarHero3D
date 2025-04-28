shader_type spatial;

uniform sampler2D texture_albedo : source_color;
uniform float scroll_speed : hint_range(-1.0, 1.0) = 0.1;
uniform float darkness_factor : hint_range(0.0, 1.0) = 1.0; // Add a darkness control

void fragment() {
	vec2 scrolled_uv = UV;
	scrolled_uv.y += TIME * scroll_speed; // Assuming vertical scroll for the road
	vec4 albedo_color = texture(texture_albedo, scrolled_uv);

	// Make it darker by multiplying the color
	ALBEDO = albedo_color.rgb * darkness_factor;
	ALPHA = albedo_color.a;
}