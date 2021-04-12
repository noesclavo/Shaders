#version 120

#define PI 3.141592653589793238462643383279502884197969

#define INPUT MotionVectors

//#define VERTICAL


uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

uniform sampler2D INPUT;

uniform float kernel_size;
uniform bool blur_vectors;

#ifdef VERTICAL
  uniform float vv_bias;
	float bias = vv_bias;
	vec2 dir = vec2(0.0, 1.0);
#else
  uniform float vh_bias;
	float bias = vh_bias;
	vec2 dir = vec2(1.0, 0.0);
#endif

vec4 gblur()
{
	vec2 xy = gl_FragCoord.xy;
	vec2 st = xy / res;


	float br = kernel_size * bias;
	float bg = kernel_size * bias;
	float bb = kernel_size * bias;
	float bm = kernel_size * bias;

	//Blur code by Lewis Saunders

	float support = max(max(max(br, bg), bb), bm) * 3.0;

	vec4 sigmas = vec4(br, bg, bb, bm);
	sigmas = max(sigmas, vec4(0.0001));

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
	vec2 st = gl_FragCoord.xy / res;
	vec4 motion_vectors = vec4(1.0);

	if (blur_vectors) {
		motion_vectors = gblur();
	} else {
		motion_vectors = texture2D(INPUT, st);
	}

	gl_FragColor = motion_vectors;
}
