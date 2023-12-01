shader_type canvas_item;

render_mode blend_mix;

uniform vec4 outline_color : source_color;
uniform int thickness;

void fragment(){
	vec4 sprite_color = texture(TEXTURE, UV);
	float alpha = -(float(thickness * thickness) * 8.0) * sprite_color.a;
	for (int x = 1; x <= thickness; ++x) {
		for (int y = 1; y <= thickness; ++y) {
			float size_x = float(x)/float(textureSize(TEXTURE, 0).x);
			float size_y = float(y)/float(textureSize(TEXTURE, 0).y);
			alpha += texture(TEXTURE, UV + vec2(size_x, 0)).a;
			alpha += texture(TEXTURE, UV + vec2(-size_x, 0)).a;
			alpha += texture(TEXTURE, UV + vec2(0, size_y)).a;
			alpha += texture(TEXTURE, UV + vec2(0, -size_y)).a;
			alpha += texture(TEXTURE, UV + vec2(size_x, size_y)).a;
			alpha += texture(TEXTURE, UV + vec2(-size_x, size_y)).a;
			alpha += texture(TEXTURE, UV + vec2(-size_x, -size_y)).a;
			alpha += texture(TEXTURE, UV + vec2(size_x, -size_y)).a;
		}
	}
	vec4 final_color = mix(sprite_color, outline_color, clamp(alpha, 0.0, 1.0));
	COLOR = vec4(final_color.rgb, clamp(abs(alpha) + sprite_color.a, 0.0, 1.0));
}