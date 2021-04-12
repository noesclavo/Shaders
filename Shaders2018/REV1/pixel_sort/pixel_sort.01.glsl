#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

float adsk_getLuminance(in vec3 color);

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;

void main(void) {
	vec2 xy = gl_FragCoord.xy;
	vec2 st = gl_FragCoord.xy / res;
	vec3 outcol = vec3(0.0);

	vec3 col;

	for (int i = 0; i < res.x; i++) {
		vec2 coords = st - vec2(i, 0) * texel;

		if (coords.x < 0 || coords.x > 1) {
			continue;
		}

		col = texture2D(Front, st - vec2(i, 0) * texel).rgb;

		float lum = adsk_getLuminance(col);

		if (floor(lum * res.x) == floor(xy.x)) {
			break;
		}

		col = vec3(0.0);
	}

	outcol = col;

	gl_FragColor.rgb = outcol;
}
