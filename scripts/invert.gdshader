shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;


void fragment(){
	
	vec4 color = vec4(texture(screen_texture, SCREEN_UV).rgb, texture(TEXTURE, UV).a);
	
	COLOR = vec4(1.0 - color.rgb,  color.a);
}