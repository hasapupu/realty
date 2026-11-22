
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform sampler2D offset_image : source_color, filter_linear;
uniform float strength : hint_range(0.0, 10.0) = 1.0;

void fragment() {
    vec4 output_color = texture(screen_texture, SCREEN_UV);

    float shift = strength * texture(offset_image, UV).r / 100.0;

    output_color.r = texture(
        screen_texture,
        SCREEN_UV + vec2(shift, 0.0)
    ).r;

    output_color.g = texture(screen_texture, SCREEN_UV).g;

    output_color.b = texture(
        screen_texture,
        SCREEN_UV - vec2(shift, 0.0)
    ).b;

    COLOR = output_color;
}
