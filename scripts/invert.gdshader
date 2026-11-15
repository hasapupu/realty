
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

void fragment() {
    vec4 screen = texture(screen_texture, SCREEN_UV);

    COLOR = vec4(vec3(1.0) - screen.rgb, screen.a);
}
