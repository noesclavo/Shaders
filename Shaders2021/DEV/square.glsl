#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform float size;
uniform float v;
uniform vec2 l;

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec2 loc = l * adsk_result_frameratio;

	st.x *= adsk_result_frameratio;

	vec2 v1 = loc - vec2(size * .5);
	vec2 v2 = loc + vec2(size * .5);

	vec2 co = smoothstep(v1, v1 + .001, st) * (1.0 - smoothstep(v2, v2 + .001, st));

	float col = co.x * co.y;

	gl_FragColor = vec4(col);
}
