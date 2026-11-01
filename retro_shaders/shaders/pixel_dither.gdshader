shader_type canvas_item;
render_mode unshaded;

// Whatever has already been drawn beneath this node, sampled nearest-neighbour.
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest, repeat_disable;

// Palette: dark (left) to light (right). Assign a GradientTexture1D here.
// repeat_disable stops a value of exactly 1.0 wrapping round to the dark end.
uniform sampler2D color_gradient : hint_default_white, filter_nearest, repeat_disable;

// Size of one "big pixel" in real screen pixels.
uniform float pixel_size : hint_range(1.0, 32.0, 1.0) = 4.0;

// Margin between big pixels, in real screen pixels. 0 = no gap.
// Gaps are filled with the darkest palette colour.
uniform float pixel_gap : hint_range(0.0, 16.0, 1.0) = 1.0;

// Number of distinct gradient colours used.
uniform int dither_levels : hint_range(2, 16) = 4;

// 0 = flat banding, 1 = full ordered dither.
uniform float dither_strength : hint_range(0.0, 1.0) = 1.0;

uniform float contrast : hint_range(0.5, 3.0) = 1.2;
uniform float brightness : hint_range(-1.0, 1.0) = 0.0;

const int BAYER4[16] = int[16](
	 0,  8,  2, 10,
	12,  4, 14,  6,
	 3, 11,  1,  9,
	15,  7, 13,  5
);

float bayer_threshold(ivec2 coord) {
	int cx = coord.x % 4;
	int cy = coord.y % 4;
	return (float(BAYER4[cy * 4 + cx]) + 0.5) / 16.0;
}

float luminance(vec3 c) {
	return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

void fragment() {
	// --- Pixelation (screen space, nearest neighbour) ---
	vec2 cell = floor(FRAGCOORD.xy / pixel_size);
	vec2 sample_uv = (cell + 0.5) * pixel_size * SCREEN_PIXEL_SIZE;
	vec3 src = textureLod(screen_texture, sample_uv, 0.0).rgb;

	// --- Pixel separation: position of this fragment inside its big pixel ---
	// Gap is carved from the right/bottom edge so cells stay grid-aligned.
	// Clamped so at least one screen pixel of colour remains per cell.
	float gap = min(pixel_gap, pixel_size - 1.0);
	vec2 local = FRAGCOORD.xy - cell * pixel_size;
	bool in_gap = gap > 0.0 && any(greaterThan(local, vec2(pixel_size - gap)));

	// --- Luminance with contrast/brightness ---
	float lum = luminance(src);
	lum = clamp((lum - 0.5) * contrast + 0.5 + brightness, 0.0, 1.0);

	// --- Ordered dither, one threshold per big pixel ---
	float steps = float(dither_levels - 1);
	float threshold = mix(0.5, bayer_threshold(ivec2(cell)), dither_strength);
	float dithered = clamp(floor(lum * steps + threshold) / steps, 0.0, 1.0);

	// --- Gaps use the darkest palette entry, as if luminance were 0 ---
	if (in_gap) {
		dithered = 0.0;
	}

	// --- Map through the palette gradient ---
	COLOR = vec4(textureLod(color_gradient, vec2(dithered, 0.5), 0.0).rgb, 1.0);
}