shader_type spatial;

uniform sampler2D albedo;

void fragment() {
	ALBEDO = texture(albedo, UV).rgb;
}
