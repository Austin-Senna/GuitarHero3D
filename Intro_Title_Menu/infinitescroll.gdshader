// Type: Canvas Item Shader
shader_type canvas_item;

uniform float scroll_speed_x = 0.05; // Adjust speed as needed
uniform float scroll_speed_y = 0.0;

void fragment() {
	// Calculate the offset based on time and speed
	vec2 offset = vec2(scroll_speed_x, scroll_speed_y) * TIME;

	// Sample the texture, offsetting the UV coordinates
	// fract() wraps UV using the texture's repeat setting
	// The TextureRect's "Tile" stretch mode handles filling the area.
	COLOR = texture(TEXTURE, fract(UV + offset));
}