
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform sampler2D offset_image : source_color, filter_linear;
uniform float strength = 1.0;

void fragment() {
    vec4 output_color = texture(screen_texture, SCREEN_UV);

    float shift = strength * texture(offset_image, SCREEN_UV).r / 100.0;

    output_color.r = texture(screen_texture, vec2(SCREEN_UV.x + shift, SCREEN_UV.y)).r;
    output_color.g = texture(screen_texture, SCREEN_UV).g;
    output_color.b = texture(screen_texture, vec2(SCREEN_UV.x - shift, SCREEN_UV.y)).b;

    COLOR = output_color;
}
