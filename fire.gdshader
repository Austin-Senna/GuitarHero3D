// Shader for the Guitar Hero track fire effect (apply to the track mesh's material)
shader_type spatial; // For 3D meshes

// Textures
uniform sampler2D base_track_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D fire_noise_texture : filter_linear_mipmap, repeat_enable; // A seamless noise/fire texture

// Control Parameters
uniform float activation_level : hint_range(0.0, 1.0) = 0.0; // 0=off, 1=fully active
uniform vec4 fire_tint : source_color = vec4(0.2, 0.5, 1.0, 1.0); // Bluish tint
uniform vec4 fire_highlight : source_color = vec4(1.0, 0.8, 0.2, 1.0); // Orange/Yellow highlights
uniform float scroll_speed = -1;
uniform float distortion_frequency = 5.0; // How dense the distortion waves are
uniform float distortion_strength = 0.02; // How much the UVs are distorted

void fragment() {
    // --- Distortion ---
    // Sample noise for distortion - use different UV scale/offset for variety
    vec2 dist_uv = UV * distortion_frequency;
    dist_uv.y += TIME * scroll_speed * 0.5; // Slowly evolving distortion pattern
    float dist_noise = texture(fire_noise_texture, dist_uv).r; // Use one channel of noise

    // Calculate distortion offset based on noise and activation level
    // Use sin/cos for wavy effect, noise adds randomness
    vec2 uv_offset;
    uv_offset.x = sin(dist_noise * 6.283) * distortion_strength * activation_level; // Distort side-to-side
    uv_offset.y = (dist_noise - 0.5) * 2.0 * distortion_strength * activation_level; // Distort along track slightly

    vec2 distorted_uv = UV + uv_offset;

    // --- Fire Effect & Scrolling UVs ---
    // Scroll the main fire texture UVs, starting from the already distorted UVs
    vec2 fire_uv = distorted_uv; // Start with distorted UVs
    fire_uv.y += TIME * scroll_speed; // Scroll along the track (adjust sign +/- if direction is wrong)

    // --- Base Track ---
    // Sample the base texture using the SAME distorted AND SCROLLED UVs as the fire
    // MODIFIED LINE: Use fire_uv instead of distorted_uv to make base scroll
    vec4 base_color = texture(base_track_texture, fire_uv);

    // --- Fire Effect (Sampling) ---
    // Sample the fire/noise texture using the scrolled and distorted UVs
    float fire_noise = texture(fire_noise_texture, fire_uv).r; // Use one channel (e.g., red)

    // Create fire color - interpolate between the tint and highlight based on noise value
    vec3 fire_color = mix(fire_tint.rgb, fire_highlight.rgb, fire_noise);

    // Modulate fire intensity by noise and activation level
    // Shaping the noise (e.g., pow(fire_noise, 2.0)) makes flames appear sharper/more defined
    float fire_intensity = pow(fire_noise, 2.0) * activation_level;

    // --- Combine ---
    // Additive Blending: Add fire color scaled by intensity to the base color's RGB components
    vec3 final_color = base_color.rgb + fire_color * fire_intensity;

    // --- Output ---
    // Set the final surface color
    ALBEDO = final_color;
    // Retain the original alpha from the base texture, unless the fire should affect transparency
    ALPHA = base_color.a;

    // Make the fire parts glow by setting emission
    // Scale emission by intensity and potentially another multiplier for brightness control
    EMISSION = fire_color * fire_intensity * 2.0; // Adjust emission brightness multiplier (2.0) as needed
}
