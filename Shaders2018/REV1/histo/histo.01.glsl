#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

float adsk_getLuminance( in vec3 color );

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform float target_luma;
uniform float whites;
uniform float blacks;

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec3 front = texture2D(Front, st).rgb;
	float matte = clamp(adsk_getLuminance(front), 0.0, 1.0);


	matte = 1.0 - abs(matte - target_luma);

	//matte = pow(matte, max(blacks, .00001));
	matte = 1.0 - matte;
	matte *= blacks;
	matte = 1.0 - matte;
	matte *= whites;

	vec4 outcol = vec4(front, matte);

	gl_FragColor = outcol;
}
