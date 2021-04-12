#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform sampler2D adsk_results_pass1;
uniform float gain;

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	//vec3 front = texture2D(Front, st).rgb;
	vec3 smear = texture2D(adsk_results_pass1, st).rgb;
	smear *= gain;

	gl_FragColor.rgb = smear;
}
