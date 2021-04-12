#version 120

#define PI 3.1415926535897932

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;

uniform bool pixel;

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec3 front = vec3(adsk_result_frameratio);

	if (pixel) {
		front = vec3(adsk_result_pixelratio);
	}

	gl_FragColor.rgb = front;
}
