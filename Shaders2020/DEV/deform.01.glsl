#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform vec2 center;
uniform float r;
uniform int op;
uniform float blend;

vec2 lut(vec2 coords) {
	//coords -= center;

	float x = -1.0 + 2.0 * coords.x;
	float y = -1.0 + 2.0 * coords.y;
	float d = sqrt(x * x + y * y);
	float a = atan(y, x);

	float u;
	float v;

	/*
	u = x * cos(2*r) - y * sin(2 * r);
	v = y * cos(2*r) - x * sin(2 * r);

	u = .3 / (r + .5 * x);
	v = 3 * a / PI;

	u = .02 * y + .03 * cos(a * 3) / r;
	v = .02 * x + .03 * cos(a * 3) / r;

	u = .1 * x / (.11 + r * .5);
	v = .1 * y / (.11 + r * .5);

	u = .5 * a / PI;
	v = sin(7*r);

	u = r * cos(a + r);
	v = r * sin(a + r);

	u = 1 / (r + .5 + .5 * sin(5 * a));
	v = a * 3 / PI;
	*/

	u = x / abs(y);
	v = 1/abs(y);

	u = u * .5 + .5;
	v = v * .5 + .5;

	coords = mix(coords, vec2(u, v), blend);


	//coords += center;

	return coords;
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	st = lut(st);

	vec3 front = texture2D(Front, st + vec2(adsk_time) * texel).rgb;

	gl_FragColor.rgb = front;
}
