// Local-Y gradient (top dark, bottom white) with a darken noise overlay.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

group_uniforms Gradient;
// Left end = top, right end = bottom. Default GradientTexture1D (black -> white) works as-is.
uniform sampler2D gradient_texture : source_color, repeat_disable, filter_linear;
// Mesh's local top and bottom. Defaults fit a 1-unit BoxMesh.
uniform float top_y = 0.5;
uniform float bottom_y = -0.5;
uniform float curve : hint_range(0.1, 5.0) = 1.0;

group_uniforms Noise;
// White = no effect, black = darkens.
uniform sampler2D noise_texture : repeat_enable, filter_linear_mipmap, hint_default_white;
uniform float noise_opacity : hint_range(0.0, 1.0) = 0.5;
uniform vec2 noise_scale = vec2(1.0, 1.0);

varying float local_y;

void vertex() {
	local_y = VERTEX.y;
}

void fragment() {
	float range = top_y - bottom_y;
	float t = (abs(range) > 0.00001) ? (top_y - local_y) / range : 0.0;
	t = pow(clamp(t, 0.0, 1.0), curve);

	vec3 base = texture(gradient_texture, vec2(t, 0.5)).rgb;

	vec3 noise = texture(noise_texture, UV * noise_scale).rgb;
	ALBEDO = mix(base, min(base, noise), noise_opacity);
}