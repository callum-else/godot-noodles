shader_type canvas_item;
render_mode unshaded;

// The dithered image beneath this node. Linear filtering helps the blur stay smooth,
// and lets each tap below blend its neighbourhood for free.
uniform sampler2D screen_texture : hint_screen_texture, filter_linear, repeat_disable;

// Horizontal reach of the bleed, in screen pixels.
uniform float bleed_radius : hint_range(0.0, 8.0) = 2.0;

// Vertical reach as a fraction of the horizontal (CRTs smear mostly sideways).
uniform float vertical_ratio : hint_range(0.0, 1.0) = 0.35;

// How strongly light spills into darker neighbours and gaps.
// Below 1.0 the gaps stay visibly darker than the pixels.
uniform float bleed_strength : hint_range(0.0, 1.0) = 0.6;

// How much the pixel bodies themselves soften toward the blurred image.
uniform float softness : hint_range(0.0, 1.0) = 0.25;

// Red/blue horizontal offset in screen pixels, for colour fringing.
uniform float chroma_shift : hint_range(0.0, 3.0) = 0.75;

// Barrel/fisheye strength. 0 = flat; higher bulges the centre outward.
uniform float fisheye_strength : hint_range(0.0, 1.0) = 0.15;

// The original 7x3 Gaussian kernel (weight = exp(-2 * |n|^2)) collapsed into 7 taps.
// Each merged tap carries the total weight of the taps it replaces and sits at their
// weighted centre, so overall brightness and spread match the original.
const float W_CENTRE = 1.0;
const float W_NEAR = 1.2118;   // original x = ±1/3 and ±2/3, merged
const float X_NEAR = 0.446;    // their weighted centre, as a fraction of bleed_radius
const float W_FAR = 0.1353;    // original x = ±1
const float W_VERT = 0.5;      // each whole off-centre row (y = ±1), merged to one tap
const float INV_TOTAL = 0.21303; // 1 / (sum of all weights = 4.6942)

vec3 tap(vec2 uv) {
	return textureLod(screen_texture, uv, 0.0).rgb;
}

// Cheap barrel distortion around the screen centre. Corners map exactly to corners,
// so the screen stays filled (no black borders) and nothing samples outside [0,1].
vec2 fisheye(vec2 uv, vec2 px) {
	float aspect = px.y / px.x;                  // width / height
	vec2 c = uv - 0.5;
	vec2 ca = c * vec2(aspect, 1.0);             // aspect-correct, so the bulge is circular
	float r2 = dot(ca, ca);
	float r2_corner = 0.25 * aspect * aspect + 0.25;
	return 0.5 + c * (1.0 + fisheye_strength * r2) / (1.0 + fisheye_strength * r2_corner);
}

void fragment() {
	vec2 px = SCREEN_PIXEL_SIZE;
	vec2 uv = fisheye(SCREEN_UV, px);

	// Read once; reused for the sharp green channel and the blur's centre tap.
	vec3 centre = tap(uv);

	// --- Chroma fringing on the sharp image only (2 extra reads) ---
	vec3 sharp = centre;
	if (chroma_shift > 0.0) {
		vec2 shift = vec2(chroma_shift * px.x, 0.0);
		sharp.r = tap(uv + shift).r;
		sharp.b = tap(uv - shift).b;
	}

	// --- Anisotropic blur, 7 taps (6 extra reads) ---
	vec3 blurred = sharp;
	if (bleed_radius > 0.0) {
		vec2 hx = vec2(bleed_radius * px.x, 0.0);
		vec2 vy = vec2(0.0, bleed_radius * vertical_ratio * px.y);
		vec2 near = hx * X_NEAR;

		blurred = centre * W_CENTRE
			+ (tap(uv + near) + tap(uv - near)) * W_NEAR
			+ (tap(uv + hx) + tap(uv - hx)) * W_FAR
			+ (tap(uv + vy) + tap(uv - vy)) * W_VERT;
		blurred *= INV_TOTAL;
	}

	// --- Combine ---
	// Soften the pixel bodies slightly, then let light (never darkness) bleed outward.
	vec3 soft = mix(sharp, blurred, softness);
	vec3 col = max(soft, blurred * bleed_strength);

	COLOR = vec4(col, 1.0);
}