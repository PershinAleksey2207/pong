shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

uniform vec2 resolution = vec2(600.0, 800.0);

// --- Настройки линзы ---
uniform float curve_power : hint_range(0.0, 1.0) = 0.15;
uniform float zoom : hint_range(1.0, 1.2) = 1.05;

// --- Настройки фосфора ---
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.8;
uniform float color_bleed : hint_range(0.0, 5.0) = 1.5;
uniform float mask_darkness : hint_range(0.0, 1.0) = 0.6;
uniform float brightness_boost : hint_range(1.0, 3.0) = 1.8;

// --- Настройки краев ---
uniform float vignette_intensity : hint_range(0.0, 5.0) = 1.2; 
uniform float border_thickness : hint_range(0.0, 0.1) = 0.02;  

// --- Настройки дрожания (Jitter) ---
uniform float jitter_intensity : hint_range(0.0, 0.01) = 0.001; // Насколько сильно экран трясется по горизонтали
uniform float jitter_speed : hint_range(0.0, 50.0) = 15.0;      // Скорость смены помех

vec2 curve(vec2 uv) {
    vec2 center = uv - 0.5;
    float aspect = resolution.x / resolution.y;
    vec2 aspect_center = center;
    aspect_center.x *= aspect; 
    float dist = dot(aspect_center, aspect_center); 
    center = center * (1.0 + curve_power * dist);
    center /= zoom;
    return center + 0.5;
}

void fragment() {
    vec2 uv = curve(SCREEN_UV);
    
    // ДОБАВЛЕНО: Эффект нестабильного аналогового сигнала (Дрожание по X)
    // Генерируем псевдослучайный шум на основе встроенного времени (TIME) и высоты строки (uv.y)
    float noise = fract(sin(dot(vec2(TIME * jitter_speed, uv.y), vec2(12.9898, 78.233))) * 43758.5453);
    // Сдвигаем координаты по горизонтали. Вычитаем 0.5, чтобы дрожание было в обе стороны (влево и вправо)
    uv.x += (noise - 0.5) * jitter_intensity;
    
    // Отсекаем жесткий выход за пределы линзы
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        
        // 1. Хроматическая аберрация и растекание
        vec2 offset = vec2(color_bleed / resolution.x, 0.0);
        
        float r = texture(screen_texture, uv - offset).r;
        float g = texture(screen_texture, uv).g;
        float b = texture(screen_texture, uv + offset).b;
        vec3 color = vec3(r, g, b);
        
        vec3 col_left = texture(screen_texture, uv - offset * 2.0).rgb;
        vec3 col_right = texture(screen_texture, uv + offset * 2.0).rgb;
        color = (color * 0.6) + (col_left * 0.2) + (col_right * 0.2);

        // 2. Сканлайны
        float scanline = sin(uv.y * resolution.y * 3.14159 * 2.0);
        scanline = scanline * 0.5 + 0.5; 
        float scan_mult = mix(1.0, scanline, scanline_intensity);
        color *= scan_mult;
        
        // 3. Фосфорная маска
        float mask_x = mod(uv.x * resolution.x * 3.0, 3.0);
        vec3 mask = vec3(1.0);
        
        if (mask_x < 1.0) {
            mask = vec3(1.0, 1.0 - mask_darkness, 1.0 - mask_darkness);
        } else if (mask_x < 2.0) {
            mask = vec3(1.0 - mask_darkness, 1.0, 1.0 - mask_darkness);
        } else {
            mask = vec3(1.0 - mask_darkness, 1.0 - mask_darkness, 1.0);
        }
        
        color *= mask;
        color *= brightness_boost;

        // 4. Виньетка 
        float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
        vignette = clamp(pow(16.0 * vignette, 0.25) * vignette_intensity, 0.0, 1.0);
        color *= vignette;
        
        // 5. Черная рамка
        float border_x = smoothstep(0.0, border_thickness, SCREEN_UV.x) * smoothstep(1.0, 1.0 - border_thickness, SCREEN_UV.x);
        float border_y = smoothstep(0.0, border_thickness, SCREEN_UV.y) * smoothstep(1.0, 1.0 - border_thickness, SCREEN_UV.y);
        color *= border_x * border_y;

        COLOR = vec4(color, 1.0);
    }
}