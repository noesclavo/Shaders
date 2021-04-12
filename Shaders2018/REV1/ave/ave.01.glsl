#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform sampler2D Back;
uniform sampler2D Matte;

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec3 front = texture2D(Front, st).rgb;
	vec3 back = texture2D(Back, st).rgb;
	float matte = texture2D(Matte, st).r;

	vec4 comp = vec4(0.0);

	comp.a = matte;
	comp.rgb = (front + back) * .5;



	gl_FragColor = comp;
}
