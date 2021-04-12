#version 120

float   adsk_getLuminance( vec3 rgb );

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform sampler2D Back;
uniform float threshold;
uniform float gain;

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec3 front = texture2D(Front, st).rgb;
	vec3 back = texture2D(Back, st).rgb;

	float outcol = 0.0;
	float diff = adsk_getLuminance(abs(front - back)) * gain;

	outcol = smoothstep(threshold, 1.0, diff);

	gl_FragColor = vec4(front, outcol);
}
