#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

float adsk_getLuminance(vec3 src);

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform float power;

void main(void) {
	vec2 xy = gl_FragCoord.xy;
	vec2 st = gl_FragCoord.xy / res;

	vec3 front = vec3(0.0);
	float c = 0.0;
	vec3 col1 = vec3(0.0);
	vec3 m = vec3(0.0);

	for (int i = 0; i < res.y; i++) {
		vec2 coords = st + vec2(i, 0) * texel;
		col1 = texture2D(Front, mix(st, coords, power)).rgb;

		float lum1 = adsk_getLuminance(col1);

		//horizonal scope
		/*
		if (floor(lum1 * res.x) == floor(xy.x)) {
			c = lum1;
			m = col1;
			break;
		}
		*/

	}

	front = m;

	gl_FragColor = vec4(front, c);
}
