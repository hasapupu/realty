
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

void fragment() {
    vec4 screen = texture(screen_texture, SCREEN_UV);
    float gray = dot(screen.rgb, vec3(0.299, 0.587, 0.114));

    COLOR = vec4(vec3(gray), screen.a);
}
