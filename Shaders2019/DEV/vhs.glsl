#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform vec2 square_size;
vec2 center = vec2(.5);

vec2 CosSin(float x) {
	vec2 si = fract(vec2(0.5,1.0) - x*2.0)*2.0 - 1.0;
	vec2 so = sign(0.5-fract(vec2(0.25,0.5) - x));
	return (20.0 / (si*si + 4.0) - 4.0) * so;
}

float rand(vec2 coords, float seed) {
	float t = adsk_time * .2;
	return fract(CosSin(dot(coords.xy, vec2(12.989 + t * seed, 78.233))) * 43758.5453).r;
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec2 s = square_size * texel;

	st -= center;
	float u = rand(1.0 + floor(st / s), .23488);
	float v = rand(ceil(st / s), .9883);
	st += center;

	st = vec2(u,v);

	vec3 front = vec3(st.x);

	gl_FragColor.rgb = front;
}
