shader_type canvas_item;

uniform int pixelation_level = 1;
uniform float crush = 1.75;
uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
    int pixel_block = pixelation_level * 2;
    
    // Размер одного блока в UV-координатах
    vec2 block_size = vec2(float(pixel_block), float(pixel_block)) * SCREEN_PIXEL_SIZE;
    
    // Координаты левого верхнего угла блока
    vec2 block_uv = floor(SCREEN_UV / block_size) * block_size;
    
    // Центр блока (берём цвет оттуда)
    vec2 center_uv = block_uv + block_size * 0.5;
    
    vec4 screen = texture(screen_texture, center_uv);
    
    float greyscale = max(screen.r, max(screen.g, screen.b));
    
    float low_color = floor(greyscale * crush) / crush;
    float high_color = ceil(greyscale * crush) / crush;
    
    float low_diff = abs(low_color - greyscale);
    float high_diff = abs(high_color - greyscale);
    
    float color_check = low_diff < high_diff ? low_color : high_color;
    float dither = color_check - greyscale;
    
    COLOR = vec4(screen.rgb + dither, 1.0);
}