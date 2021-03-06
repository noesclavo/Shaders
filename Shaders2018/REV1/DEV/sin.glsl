#version 120

#define PI 3.141592653589793238462643383279502884197969
#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

vec2 CosSin(float x) {
	vec2 si = fract(vec2(0.5,1.0) - x*2.0)*2.0 - 1.0;
	vec2 so = sign(0.5-fract(vec2(0.25,0.5) - x));
	return (20.0 / (si*si + 4.0) - 4.0) * so;
}

float rand(vec2 coords) {
	return fract(CosSin(dot(coords.xy, vec2(12.989 + mod(adsk_time, 10.0), 78.233))) * 43758.5453).r;
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res - vec2(0.0, .5);
	vec4 col = vec4(0.);

	col.r = rand(st);

	gl_FragColor = col;
}
