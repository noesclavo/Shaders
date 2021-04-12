#version 120
#extension GL_ARB_shader_texture_lod : enable

#define ratio adsk_result_frameratio
#define PI 3.141592653589793238462643383279502884197969

float   adsk_getLuminance( vec3 rgb );

uniform float ratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform sampler2D Back;
uniform float r_gamma;
uniform float g_gamma;
uniform float b_gamma;
uniform float m_gamma;
uniform float gain;
uniform bool output_matte;


void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec3 front = texture2D(Front, st).rgb;
	vec3 back = texture2D(Back, st).rgb;
	vec3 dif = abs(front - back);

	float r = 1.0 - r_gamma;
	float g = 1.0 - g_gamma;
	float b = 1.0 - b_gamma;
	float m = 1.0 - m_gamma;

	dif.r = pow(dif.r, max(.01, r));
	dif.g = pow(dif.g, max(.01, g));
	dif.b = pow(dif.b, max(.01, b));

	float matte = adsk_getLuminance(dif);

	matte = pow(matte, max(.01, m));
	matte *= gain / 100.0;

	if (output_matte) {
		dif = vec3(matte);
	}



	gl_FragColor = vec4(dif, matte);
}
