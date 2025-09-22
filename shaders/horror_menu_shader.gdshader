shader_type canvas_item;

// Parámetros del shader de horror
uniform float time_speed : hint_range(0.1, 3.0) = 1.0;
uniform float distortion_strength : hint_range(0.0, 0.1) = 0.02;
uniform float flicker_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float noise_intensity : hint_range(0.0, 0.5) = 0.15;
uniform float vignette_strength : hint_range(0.0, 2.0) = 0.8;
uniform float blood_tint : hint_range(0.0, 1.0) = 0.2;
uniform float darkness_pulse : hint_range(0.0, 1.0) = 0.4;

// Función de ruido
float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

// Función de ruido suave
float noise(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
    vec2 uv = SCREEN_UV;
    float time = TIME * time_speed;
    
    // Distorsión siniestra
    vec2 distortion = vec2(
        sin(time * 2.0 + uv.y * 10.0) * distortion_strength,
        cos(time * 1.5 + uv.x * 8.0) * distortion_strength * 0.5
    );
    
    // Parpadeo aleatorio
    float flicker = 1.0 - flicker_intensity * random(vec2(time * 0.1)) * 
                    step(0.95, random(vec2(time * 0.05)));
    
    // Ruido de película vieja
    float film_noise = noise(uv * 800.0 + time * 50.0) * noise_intensity;
    
    // Viñeta oscura
    vec2 center = uv - 0.5;
    float vignette = 1.0 - dot(center, center) * vignette_strength;
    vignette = smoothstep(0.0, 1.0, vignette);
    
    // Pulso de oscuridad
    float pulse = sin(time * 0.8) * 0.5 + 0.5;
    float darkness = 1.0 - darkness_pulse * pulse * 0.3;
    
    // Obtener color base con distorsión
    vec4 color = texture(TEXTURE, UV + distortion);
    
    // Aplicar tinte rojizo (sangre)
    color.rgb = mix(color.rgb, vec3(0.8, 0.1, 0.1), blood_tint * pulse * 0.3);
    
    // Aplicar efectos
    color.rgb *= flicker;
    color.rgb += film_noise;
    color.rgb *= vignette;
    color.rgb *= darkness;
    
    // Desaturar ligeramente para look más tétrico
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    color.rgb = mix(color.rgb, vec3(gray), 0.3);
    
    // Aumentar contraste
    color.rgb = pow(color.rgb, vec3(1.2));
    
    COLOR = color;
}