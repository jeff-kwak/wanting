shader_type canvas_item;

uniform bool active = false;
uniform vec4 color: source_color;

void fragment() {
	vec4 prev = texture(TEXTURE, UV);
	vec4 flash = vec4(color.rgb, prev.a);
	vec4 change = prev;
	if(active == true) {
		change = flash;
	}

	COLOR = change;
}
