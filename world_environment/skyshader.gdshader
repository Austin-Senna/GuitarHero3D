// Use sky shader type for WorldEnvironment
shader_type sky;

// Uniforms to control the appearance and scrolling from the Inspector
// Changed default scroll direction to Z-axis
uniform vec3 scroll_direction = vec3(0.0, 0.0, 1.0); // Direction to scroll towards (Z-axis default)
uniform float scroll_speed : hint_range(0.0, 0.5) = 0.02;      // How fast the stars scroll
uniform float star_density : hint_range(0.9, 0.999) = 0.99;    // Threshold for star visibility (higher = fewer)
uniform float star_brightness : hint_range(1.0, 20.0) = 8.0;   // Exponent for star brightness/size
uniform float star_scale : hint_range(10.0, 500.0) = 150.0;    // Scale factor for star field

// Simple pseudo-random number generator (hash function) for 3D
// Input: 3D vector, Output: float between 0.0 and 1.0
float hash31(vec3 p) {
    p = fract(p * vec3(413.897, 581.423, 637.193));
    vec3 swizzled_p = vec3(p.y, p.z, p.x);
    float dot_result = dot(p, swizzled_p + 19.19);
    p = p + vec3(dot_result);
    return fract((p.x + p.y) * p.z);
}

// Function to generate stars based on a 3D direction vector
float generate_stars(vec3 direction) {
    // Scale the direction vector using the star_scale uniform
    // DO NOT normalize the direction here - let the offset calculated in sky() persist
    vec3 scaled_dir = direction * star_scale;
    float random_value = hash31(scaled_dir);
    float stars = pow(smoothstep(star_density, 1.0, random_value), star_brightness);
    return stars;
}

// Function to map 2D coordinates (assuming range -1 to 1) to a 3D hemisphere direction
vec3 map_2d_to_hemisphere(vec2 coords_2d) {
    float z_sq = 1.0 - dot(coords_2d, coords_2d);
    if (z_sq < 0.0) {
        // Outside the unit circle, project onto the edge and keep z=0
        return normalize(vec3(coords_2d, 0.0));
    } else {
        // Inside unit circle, calculate z for unit sphere
        return vec3(coords_2d.x, coords_2d.y, sqrt(z_sq));
    }
}

void sky() {
    // --- Adapt SKY_COORDS (assuming vec2) to a 3D direction ---
    // Assume SKY_COORDS is vec2 in 0..1 range, map to -1..1
    vec2 coords_2d = vec2(SKY_COORDS) * 2.0 - 1.0; // Cast to vec2 and map range

    // Convert the 2D coordinates to a base 3D direction on a hemisphere
    vec3 base_direction = map_2d_to_hemisphere(coords_2d);

    // --- Scrolling Logic (3D) ---
    vec3 normalized_scroll_dir = vec3(0.0);
    if (length(scroll_direction) > 0.001) {
         normalized_scroll_dir = normalize(scroll_direction);
    }

    // Calculate the offset based on time and speed, applying it to the base direction
    vec3 offset_sky_coords = base_direction + normalized_scroll_dir * TIME * scroll_speed;
    // --- End Scrolling Logic ---

    // Generate the star value based on the calculated offset direction
    // Pass the offset direction directly to generate_stars
    float star_value = generate_stars(offset_sky_coords);

    // Set the final color
    COLOR = vec3(star_value);
    ALPHA = 1.0;
}
