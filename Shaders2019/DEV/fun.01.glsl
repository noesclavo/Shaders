#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform float ampr;
uniform float ampg;
uniform float ampb;

void main(void) {
	vec2 st = gl_FragCoord.xy / res;
	vec2 uv = st;

	vec3 front = texture2D(Front, uv).rgb;
	vec3 outcol = front;

	uv = uv * vec2(2.0) - vec2(1.);

	float t = adsk_time * .1;
	t = 1;

	float r = 0.0;
	r = uv.y + sin(uv.x * 10 + r) * ampr * front.r;
	r = 1.0 - smoothstep(.0, .025, abs(r - 0));

	float g = 0.0;
	g = uv.y + sin(uv.x * 10 + g) * ampg * front.g;
	g = 1.0 - smoothstep(.0, .025, abs(g - 0));

	float b = 0.0;
	b = uv.y + sin(uv.x *10 + b) * ampb * front.b;
	b = 1.0 - smoothstep(.0, .025, abs(b - 0));

/*
	float r = sqrt(uv.x * uv.x + uv.y * uv.y);
	float theta = atan(uv.y, uv.x);
	float phi = acos(-1 / r);
	*/

	outcol = vec3(r,g,b);

	gl_FragColor.rgb = outcol;
}
