shader_type canvas_item;
render_mode unshaded, skip_vertex_transform;

const float curvature = 7.0;
const float vignette_multiplier = 2.0;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;
uniform float time_speed: hint_range(0.1, 5.0) = 1.0;
uniform float flicker_intensity: hint_range(0.0, 0.3) = 0.05;
uniform float noise_intensity: hint_range(0.0, 0.1) = 0.02;
uniform float distortion_intensity: hint_range(0.0, 0.01) = 0.003;

// Función de ruido simple
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	float time = TIME * time_speed;
	
	vec2 centered_uv = SCREEN_UV * 2.0 - 1.0;
	
	// Distorsión temporal sutil
	vec2 distortion = vec2(
		sin(time * 3.0 + centered_uv.y * 10.0) * distortion_intensity,
		cos(time * 2.0 + centered_uv.x * 8.0) * distortion_intensity * 0.5
	);
	
	vec2 uv_offset = (centered_uv + distortion).yx / curvature;
	vec2 warped_uv = centered_uv + distortion + (centered_uv + distortion) * uv_offset * uv_offset;
	
	vec3 cutoff = vec3(step(abs(warped_uv.x), 1.0) * step(abs(warped_uv.y), 1.0));
	
	// Scanlines con movimiento
	vec3 scanlines = vec3(sin(2.0 * (warped_uv.y + time * 0.1) * 180.0) * 0.1 + 0.9);
	
	// Vignette con pulsación sutil
	float vignette_pulse = 1.0 + sin(time * 4.0) * 0.1;
	vec3 vignette = vec3(length(pow(abs(centered_uv), vec2(4.0)) / 3.0)) * vignette_pulse;
	
	// Color base de la pantalla
	vec3 screen_color = textureLod(screen_texture, (warped_uv + 1.0) / 2.0, 0.2).rgb * cutoff * scanlines;
	
	// Flicker aleatorio
	float flicker = 1.0 - random(vec2(time * 0.1)) * flicker_intensity;
	screen_color *= flicker;
	
	// Ruido de TV vieja
	float noise = (random(SCREEN_UV + time) - 0.5) * noise_intensity;
	screen_color += vec3(noise);
	
	// Aplicar vignette
	screen_color -= vignette * vignette_multiplier;
	
	// Efecto de interferencia ocasional
	float interference = step(0.98, random(vec2(time * 0.05))) * 0.3;
	screen_color += vec3(interference * sin(warped_uv.y * 100.0 + time * 50.0));
	
	COLOR = vec4(screen_color, 1.0);
}