#version 120


// Change the folling 4 lines to suite
#define VERTICAL
#define STRENGTH_CHANNEL
#define FRONT adsk_results_pass5
#define STRENGTH adsk_results_pass3
#define DEPTH adsk_results_pass1

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

uniform sampler2D FRONT;
uniform sampler2D STRENGTH;
uniform sampler2D DEPTH;

uniform bool strength_are_vectors;
uniform bool show_vectors;

#define PI 3.141592653589793238462643383279502884197969

#ifdef VERTICAL
	uniform float v_bias;
	float bias = v_bias;
	const vec2 dir = vec2(0.0, 1.0);
#else
	uniform float h_bias;
	float bias = h_bias;
	const vec2 dir = vec2(1.0, 0.0);
#endif

uniform float blur_amount;
uniform float blur_red;
uniform float blur_green;
uniform float blur_blue;

vec4 gblur()
{
	vec2 xy = gl_FragCoord.xy;

	vec3 s3 = vec3(0.0);
	float strength = 0.0;
	float depth = texture2D(DEPTH, xy * texel).a;

	if (depth > 0.0 && depth < 1.0) {
		s3 = texture2D(STRENGTH, xy * texel).rgb;
		strength = abs(s3.g);
	}

	//strength = 1.0;

	//The blur function is the work of Lewis Saunders.

	float br = blur_red * blur_amount * bias * strength;
	float bg = blur_green * blur_amount * bias * strength;
	float bb = blur_blue * blur_amount * bias * strength;
	float bm = blur_amount * bias * strength;

	float support = max(max(max(br, bg), bb), bm) * 3.0;

	vec4 sigmas = vec4(br, bg, bb, bm);
	sigmas = max(sigmas, 0.0001);

	vec4 gx, gy, gz;
	gx = 1.0 / (sqrt(2.0 * PI) * sigmas);
	gy = exp(-0.5 / (sigmas * sigmas));
	gz = gy * gy;

	vec4 a = gx * texture2D(FRONT, xy * texel);
	vec4 energy = gx;
	gx *= gy;
	gy *= gz;

	for(float i = 1; i <= support; i++) {
    a += gx * texture2D(FRONT, (xy - i * dir) * texel);
    a += gx * texture2D(FRONT, (xy + i * dir) * texel);
		energy += 2.0 * gx;
		gx *= gy;
		gy *= gz;
	}

	a /= energy;

	if (show_vectors) {
		a.rgb = s3;
	}

	return a;
}

void main(void)
{
	gl_FragColor = gblur();
}
