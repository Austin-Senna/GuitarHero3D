
// Use sky shader type for WorldEnvironment
shader_type sky;

// Uniforms to control the appearance and scrolling from the Inspector
uniform vec3 scroll_direction = vec3(0.0, 0.0, 1.0); // Direction streaks move towards (Z-axis default)
uniform float scroll_speed : hint_range(0.0, 10.0) = 1.5;     // How fast the streaks move
uniform float streak_density : hint_range(1.0, 100.0) = 25.0; // Controls length/frequency of streaks along scroll direction
uniform float pattern_scale : hint_range(10.0, 500.0) = 80.0; // Scale for the sideways noise pattern creating streaks
uniform float streak_sharpness : hint_range(0.5, 0.99) = 0.92; // How sharp/defined the streaks are (higher = sharper, less blurry)
uniform float streak_brightness : hint_range(0.5, 10.0) = 2.0; // Overall brightness multiplier

// Simple pseudo-random number generator (hash function) for 2D
// Used for the pattern perpendicular to the streaks
// Input: 2D vector, Output: float between 0.0 and 1.0
float hash21(vec2 p) {
    // Standard simple hash
    p = fract(p * vec2(413.897, 581.423));
    p += dot(p, p.yx + 19.19);
    return fract(p.x * p.y);
}

// Function to map 2D coordinates (assuming range -1 to 1) to a 3D hemisphere direction
// Needed because we assume SKY_COORDS is behaving like vec2 in this environment
vec3 map_2d_to_hemisphere(vec2 coords_2d) {
    float z_sq = 1.0 - dot(coords_2d, coords_2d);
    if (z_sq < 0.0) {
        // Outside the unit circle, project onto the edge (keeps Z=0)
        return normalize(vec3(coords_2d, 0.0));
    } else {
        // Inside unit circle, calculate z for unit sphere
        return vec3(coords_2d.x, coords_2d.y, sqrt(z_sq));
    }
}

void sky() {
    // --- Adapt SKY_COORDS (assuming vec2) to a 3D direction ---
    // Cast SKY_COORDS to vec2 and map its assumed 0..1 range to -1..1
    vec2 coords_2d = vec2(SKY_COORDS) * 2.0 - 1.0;
    // Convert the 2D coordinates to a base 3D direction on a hemisphere
    vec3 base_direction = map_2d_to_hemisphere(coords_2d);

    // --- Scrolling Logic ---
    // Ensure scroll direction is normalized
    vec3 normalized_scroll_dir = vec3(0.0, 0.0, 1.0); // Default Z
    if (length(scroll_direction) > 0.001) {
         normalized_scroll_dir = normalize(scroll_direction);
    }
    // Calculate the coordinate offset based on time and speed
    vec3 offset_coords = base_direction + normalized_scroll_dir * TIME * scroll_speed;

    // --- Streak Generation ---
    // Project the offset coordinate onto the axis parallel to scroll direction
    float coord_along_scroll = dot(offset_coords, normalized_scroll_dir);
    // Project the offset coordinate onto the plane perpendicular to scroll direction
    vec3 coord_perpendicular = offset_coords - coord_along_scroll * normalized_scroll_dir;

    // Create a repeating pattern along the scroll direction using fract()
    // This forms the basis of the streaks' length and repetition
    float band_pattern = fract(coord_along_scroll * streak_density);

    // Create noise based on the coordinates perpendicular to the scroll direction
    // We use the XY components of the perpendicular vector for the 2D hash
    // This noise defines the shape/position of streaks sideways
    float side_noise = hash21(coord_perpendicular.xy * pattern_scale);

    // Combine the repeating band pattern and the side noise
    // Multiplying them makes the noise pattern appear within the bands
    float combined_pattern = band_pattern * side_noise;

    // Use smoothstep to turn the combined pattern into sharp streaks
    // Values below streak_sharpness become 0, values above 1 become 1, with a smooth transition.
    float streak_value = smoothstep(streak_sharpness, 1.0, combined_pattern);

    // Apply overall brightness control
    streak_value *= streak_brightness;

    // --- Final Color ---
    // Set the pixel color based on the calculated streak intensity
    COLOR = vec3(streak_value); // White streaks
    ALPHA = 1.0; // Fully opaque
}
