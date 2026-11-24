shader_type spatial;

uniform sampler2D albedo;

void fragment() {
	vec2 pixel_size = 1.0 / vec2(textureSize(albedo, 0));
	vec4 base_albedo = texture(albedo, UV);
	
	float scan_line = 0.5 * step(4., mod(UV.y / pixel_size.y-1.,6.)) + 0.5 * step(2., mod(UV.y / pixel_size.y-2.,6.));
	
	vec4 colour = vec4(0.);
	for (int x=0;x<3;x++){
		colour += 1./6. * texture(albedo, UV+vec2(pixel_size.x*float(x),0.));
		colour += 1./6. * texture(albedo, UV+vec2(-pixel_size.x*float(x),0.));
	}
	colour.rgb *= 1. - (0.5*scan_line-0.5*(colour.r*0.3+colour.g*0.59+colour.b*0.11));
	ALBEDO = colour.rgb;
}
