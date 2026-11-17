shader_type spatial;

uniform float minimum_level;
uniform float maximum_level;
uniform sampler2D gradient;
varying vec3 world_position;

void vertex() {
    world_position = VERTEX;
}

void fragment() {
	float t = clamp((world_position.y - minimum_level) / (maximum_level - minimum_level), 0.0, 1.0);
	ALBEDO = texture(gradient, vec2(t, 0.5)).xyz;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
