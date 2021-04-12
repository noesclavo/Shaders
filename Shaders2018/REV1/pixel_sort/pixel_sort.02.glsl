#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

float adsk_getLuminance(in vec3 color);

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D adsk_results_pass1;
uniform bool bypass;
uniform bool bypass2;
uniform float threshold;
uniform int val;

void main(void) {
	vec2 xy = gl_FragCoord.xy;
	vec2 st = gl_FragCoord.xy / res;
	vec4 outcol = vec4(0.0);
	vec3 col = vec3(0.0);
	float lum = 0.0;

	if (bypass) {
		col = texture2D(adsk_results_pass1, st).rgb;
	} else {
		int v = val;

		if (val < 1) {
			v = 1;
		}

		for (int i = 0; i < res.x; i+=v) {
			vec2 coords = st - vec2(i, 0) * texel;

			if (coords.x < 0 || coords.x > 1) {
				//continue;
			}

			col = texture2D(adsk_results_pass1, coords).rgb;

			lum = adsk_getLuminance(col);

			if (lum > 0) {
				col -= distance(st.x, coords.x);
				break;
			}
		}
	}

	outcol = vec4(col, lum);


	gl_FragColor = outcol;
}
