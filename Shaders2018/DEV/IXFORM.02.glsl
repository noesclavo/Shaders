#version 120

// Change the folling 4 lines to suite
#define INPUT Strength
//#define VERTICAL
//#define STRENGTH_CHANNEL
#define CENTER vec2(.5)

float   adsk_getLuminance( vec3 rgb );

#define ratio adsk_result_frameratio
#define PI 3.141592653589793238462643383279502884197969

uniform float ratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

uniform sampler2D INPUT;

uniform float blur_vamount;
uniform bool strength_are_vectors;
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

uniform bool matte_is_strength;

vec4 gblur()
{
	vec2 xy = gl_FragCoord.xy;
	vec2 st = xy / res;


	float br = blur_vamount * bias;
	float bg = blur_vamount * bias;
	float bb = blur_vamount * bias;
	float bm = blur_vamount * bias;

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

			// Is a xy guassian blur or a bidirectional blur

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
	vec4 strength = vec4(1.0);

	if (strength_are_vectors && blur_vectors) {
		strength = gblur();
	} else {
		strength = texture2D(INPUT, st);
	}

	gl_FragColor = strength;
}
