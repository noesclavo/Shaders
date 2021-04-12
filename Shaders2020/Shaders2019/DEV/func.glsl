#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform float blend;
uniform bool c;

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	//vec3 front = texture2D(Front, st).rgb;
	vec2 coords = st;

	if (c) {
		coords = st * 2.0 - 1.0;
	}

	float f = sqrt(coords.x * coords.y);
	vec4 col = vec4(f);
	vec2 uv = vec2(f);

	uv = sin(st);
	uv.x = sqrt(coords.x * coords.x + coords.y + coords.y);
	uv.y = atan(coords.y / coords.x);


	uv = mix(st, uv, blend);

	st = mix(st, uv, blend);
	col = texture2D(Front, st);

	gl_FragColor = col;
}
