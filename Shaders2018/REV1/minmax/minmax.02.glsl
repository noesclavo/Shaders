#version 120

#define PI 3.141592653

//#define VERTICAL

#define INPUT adsk_results_pass1
uniform sampler2D INPUT;

#define STRENGTH_CHANNEL

uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
uniform int repeat;

vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

#ifdef STRENGTH_CHANNEL
	uniform sampler2D Strength;
#endif

uniform bool matte_is_strength;
uniform bool blur_channels;

uniform float blur_amount;
uniform float blur_red;
uniform float blur_green;
uniform float blur_blue;
float blur_matte = 1.0;

#ifdef VERTICAL
	uniform float v_bias;
	float bias = v_bias * adsk_result_pixelratio;
	vec2 dir = vec2(0.0, 1.0);
#else
	uniform float h_bias;
	float bias = h_bias;
	vec2 dir = vec2(1.0, 0.0);
#endif

vec2 repeat_coords(vec2 coords) {
	//tile
	if (repeat == 1) {
		if (coords.x > 1.0 || coords.x < 0.0) {
			coords.x = fract(coords.x);
		}
		if (coords.y > 1.0 || coords.y < 0.0) {
			coords.y = fract(coords.y);
		}
	//mirror
	} else if (repeat == 2) {
		if (mod(floor(coords.x), 2) != 0) {
			coords.x = 1.0 - fract(coords.x);
		} else {
			coords.x = fract(coords.x);
		}
		if (mod(floor(coords.y), 2) != 0.0) {
			coords.y = 1.0 - fract(coords.y);
		} else {
			coords.y = fract(coords.y);
		}
	}

	return coords;
}


vec4 blur()
{
	vec2 uv = gl_FragCoord.xy;

	float strength = 1.0;

	//Optional texture used to weight amount of blur
	#ifdef STRENGTH_CHANNEL
		strength = texture2D(Strength, uv * texel).r;
	#endif

	float br = blur_red * blur_amount * bias * strength * .1;
	float bg = blur_green * blur_amount * bias * strength * .1;
	float bb = blur_blue * blur_amount * bias * strength * .1;
	float bm = blur_matte * blur_amount * bias * strength * .1;

	if (! blur_channels) {
		br = 1.0 * bias * strength * blur_amount;
		bg = 1.0 * bias * strength * blur_amount;
		bb = 1.0 * bias * strength * blur_amount;
		bm = 1.0 * bias * strength * blur_amount;
	}

	//http://http.developer.nvidia.com/GPUGems3/gpugems3_ch40.html
	vec4 sigma = vec4(br, bg, bb, bm);
	sigma = max(sigma, 0.000001);

	vec4 g0 = 1.0 / (sqrt(2.0 * PI) * sigma);
	vec4 g1 = exp(-0.5 / (sigma * sigma));
	vec4 g2 = g1 * g1;

	vec2 st = uv * texel;

	vec4 blurred = g0 * texture2D(INPUT, st);

	vec4 norm = g0;
	g0 *= g1;
	g1 *= g2;

	vec4 mini = vec4(1.0);
	vec4 maxi = vec4(0.0);

	for(float i = 1; i <= blur_amount * bias * strength * 3.0; i++) {
		st = (uv - i * dir) * texel;
		st = repeat_coords(st);

    blurred = g0 * texture2D(INPUT, st);
		blurred /= g0;

		mini = min(blurred, mini);
		maxi = max(blurred, maxi);

		st = (uv + i * dir) * texel;
		st = repeat_coords(st);

  	blurred = g0 * texture2D(INPUT, st);
		blurred /= g0;

		mini = min(blurred, mini);
		maxi = max(blurred, maxi);

		g0 *= g1;
		g1 *= g2;
	}

	blurred = (mini + maxi) * vec4(.5);


	return blurred;
}

void main(void)
{
	gl_FragColor = blur();
}
