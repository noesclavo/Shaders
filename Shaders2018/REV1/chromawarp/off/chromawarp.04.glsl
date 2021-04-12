#version 120

#define ratio adsk_result_frameratio
#define FrontPremult adsk_results_pass1
#define Warped adsk_results_pass3
#define Strength adsk_results_pass2

float adsk_getLuminance( in vec3 color );

uniform sampler2D FrontPremult;
uniform sampler2D Warped;
uniform sampler2D Strength;

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform float rotation;
uniform float uniform_scale;
uniform vec2 scale;
uniform vec2 center;
uniform int samples;
uniform bool lat;

vec4 offset_color(float amount)
{
	//when times goes past half samples lo is black;
	float lo = step(amount ,0.5);
  float hi = 1.0 - lo;

	float a = 1.0 / 6.0;
	float b = 5.0 / 6.0;

	// times gets closer to samples, x gets brighter, when times == samples, x is clamped to white;
	float x = clamp( (amount - a) / (b - a), 0.0, 1.0 );

	//when x gets brighter, w becomes darker
	float w = clamp(1.0 - abs(2.0 * x - 1.0), 0.0, 1.0);

	// times starts red and as it gets closer to samples it goes orange, green, blue
	vec3 rgb = vec3(lo, 1.0, hi) * vec3(1.0 - w, w, 1.0 - w);

	// if times starts at 0 and goes to 3, the result is, dark, bright, darker dark
	float lum = adsk_getLuminance(rgb);

	// linearize

	vec4 color = vec4(rgb, lum);

	return color;
}

vec2 rotate_coords(vec2 coords, float r)
{
	float rot = radians(r);

	mat2 rm = mat2(
		cos(rot), sin(rot),
		-sin(rot), cos(rot)
	);

	coords -= center;
	coords.x *= ratio;
	coords *= rm;
	coords.x /= ratio;
	coords += center;

	return coords;
}

vec2 scale_coords(vec2 coords, vec2 scale) {
	coords -= center;
	coords /= scale;
	coords += center;

	return coords;
}

vec2 translate_coords(vec2 coords, vec2 t) {
	coords -= t / res;

	return coords;
}

vec2 repeat_coords(vec2 coords, int repeat) {
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

vec4 chroma_warp(vec2 st, float strength, int pass)
{
	vec4 warped = vec4(0.0);
	vec4 total = vec4(0.0);
	float sample_norm = 1.0 / float(samples);

	for (int i = 0; i < samples; i++) {
		float amount = float(i) * sample_norm;
		vec4 color = offset_color(amount);
		vec2 scale_val = mix(vec2(1.0), (scale / vec2(100)) * (vec2(uniform_scale) / vec2(100)), strength * amount);

		vec2 coords = st;

		//coords = rotate_coords(st, rotation * strength * amount);
		coords = scale_coords(coords, scale_val);
		//coords = translate_coords(coords, translate * strength * amount);

		coords.x += .5;
		coords = repeat_coords(coords, 1);
		warped += color * texture2D(FrontPremult, coords);

		total += color;
	}

	warped /= total;

	return warped;
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;
	vec4 warped = texture2D(Warped, st);

	if (lat) {
		float strength = texture2D(Strength, st).r;

		vec2 coords = st;
		coords.x -= .5;
		coords = repeat_coords(coords, 1);
		vec4 warped2 = chroma_warp(coords, strength, 0);
		float alpha = distance(st.x, .5) * 2.0;

		warped = mix(warped, warped2, alpha);

	}


	gl_FragColor = warped;
}
