shader_type spatial;
render_mode unshaded;
 
uniform vec4 color : source_color = vec4(1.0);
uniform float alpha : hint_range(0.0, 1.0, 0.01) = 0.25;
 
void fragment() {
	ALBEDO = color.rgb;
	ALPHA = alpha;
}