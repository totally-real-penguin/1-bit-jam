shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform vec4 primary: source_color = vec4(vec3(0), 1.0);
uniform vec4 secondary: source_color = vec4(1.0);


void fragment() {
	vec3 c = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	if (c == vec3(0)) {
		COLOR = primary;
	}
	 else if (c == vec3(1)) {
		COLOR = secondary;
	}
}
