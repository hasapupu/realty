
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE :
    hint_screen_texture,
    repeat_disable,
    filter_linear;

uniform float amplitude : hint_range(0.0, 0.05) = 0.01;
uniform float speed : hint_range(0.0, 2.0) = 1.0;
uniform float frequency : hint_range(0.0, 50.0) = 15.0;

void fragment() {
    vec2 uv = SCREEN_UV;

    float time = TIME * speed;

    uv.x += sin(uv.y * frequency + time * 3.0)
        * amplitude;

    uv.y += sin(uv.x * frequency + time * 2.0)
        * amplitude;

    COLOR = textureLod(SCREEN_TEXTURE, uv, 0.0);
}
