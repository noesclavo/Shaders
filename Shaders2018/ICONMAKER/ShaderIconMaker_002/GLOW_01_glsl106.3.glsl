#version 120

#define VERTICAL

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

uniform sampler2D adsk_results_pass1;
uniform sampler2D adsk_results_pass2;

uniform bool strength_are_vectors;
uniform float vector_blur_mult;

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
uniform float v_gamma;

vec4 gblur()
{
	vec2 xy = gl_FragCoord.xy;

	//The blur function is the work of Lewis Saunders.

	float br = blur_amount * bias * vector_blur_mult;
	float bg = blur_amount * bias * vector_blur_mult;
	float bb = blur_amount * bias * vector_blur_mult;
	float bm = blur_amount * bias * vector_blur_mult;

	float support = max(max(max(br, bg), bb), bm) * 3.0;

	vec4 sigmas = vec4(br, bg, bb, bm);
	sigmas = max(sigmas, 0.0001);

	vec4 gx, gy, gz;
	gx = 1.0 / (sqrt(2.0 * PI) * sigmas);
	gy = exp(-0.5 / (sigmas * sigmas));
	gz = gy * gy;

	vec4 a = gx * texture2D(adsk_results_pass2, xy * texel);
	vec4 energy = gx;
	gx *= gy;
	gy *= gz;

	for(float i = 1; i <= support; i++) {
    a += gx * texture2D(adsk_results_pass2, (xy - i * dir) * texel);
    a += gx * texture2D(adsk_results_pass2, (xy + i * dir) * texel);
		energy += 2.0 * gx;
		gx *= gy;
		gy *= gz;
	}

	a /= energy;

	return a;
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec4 strength = vec4(0.0);

	if (strength_are_vectors) {
		float g = max(v_gamma, .1);
		strength = gblur();
		strength.r = pow(strength.r, g);
		strength.g = pow(strength.g, g);
		strength.b = pow(strength.b, g);
	} else {
		strength = texture2D(adsk_results_pass1, st);
	}

	gl_FragColor = strength;
}
