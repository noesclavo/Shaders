#version 120

#define PI 3.141592653589793238462643383279502884197969

#define INPUT adsk_results_pass1
#define Strength adsk_results_pass3
#define VERTICAL
#define STRENGTH_CHANNEL

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

uniform sampler2D INPUT;

#ifdef STRENGTH_CHANNEL
	uniform sampler2D Strength;
#endif

uniform bool matte_is_strength;
uniform bool bidirectional;
uniform bool blur_channels;

uniform float blur_amount;
uniform float blur_red;
uniform float blur_green;
uniform float blur_blue;
float blur_matte = 1.0;

uniform int blur_type;
uniform vec2 direction;
uniform bool use_angle;
uniform float angle;

#ifdef VERTICAL
	uniform float v_bias;
	float bias = v_bias;
	vec2 dir = vec2(0.0, 1.0);
#else
	uniform float h_bias;
	float bias = h_bias;
	vec2 dir = vec2(1.0, 0.0);
#endif

vec4 gblur()
{
	vec2 xy = gl_FragCoord.xy;

	float strength = 1.0;

	// Optional texture used to weight amount of blur
	#ifdef STRENGTH_CHANNEL
		if (matte_is_strength) {
			strength = texture2D(INPUT, gl_FragCoord.xy / res).a;
		} else {
			strength = abs(texture2D(Strength, gl_FragCoord.xy / res).r);
		}
	#endif

	//Blur code by Lewis Saunders
	float br = blur_red * blur_amount * bias * strength;
	float bg = blur_green * blur_amount * bias * strength;
	float bb = blur_blue * blur_amount * bias * strength;
	float bm = blur_matte * blur_amount * bias * strength;

	if (! blur_channels) {
		br = 1.0 * bias * strength * blur_amount;
		bg = 1.0 * bias * strength * blur_amount;
		bb = 1.0 * bias * strength * blur_amount;
		bm = 1.0 * bias * strength * blur_amount;
	}

	float support = max(max(max(br, bg), bb), bm) * 3.0;

	vec4 sigmas = vec4(br, bg, bb, bm);
	sigmas = max(sigmas, 0.0001);

	vec4 gx, gy, gz;
	gx = 1.0 / (sqrt(2.0 * PI) * sigmas);
	gy = exp(-0.5 / (sigmas * sigmas));
	gz = gy * gy;

	vec4 a = gx * texture2D(INPUT, xy * texel);
	vec4 energy = gx;
	gx *= gy;
	gy *= gz;

	for(float i = 1; i <= support; i++) {
    a += gx * texture2D(INPUT, (xy - i * dir) * texel);
  	a += gx * texture2D(INPUT, (xy + i * dir) * texel);
		energy += 2.0 * gx;

		gx *= gy;
		gy *= gz;
	}

	a /= energy;

	return a;
}

void main(void)
{
	if (blur_type == 0) {
		gl_FragColor = gblur();
	} else {
		gl_FragColor = texture2D(INPUT, gl_FragCoord.xy * texel);
	}
}
