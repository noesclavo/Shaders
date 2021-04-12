#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

float adsk_getLuminance( in vec3 color );

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform int length;

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec4 col = vec4(0.0);
	vec2 dir = vec2(1.0, 0.0);
	int pass = 0;

	for (int i = 0 ; i < res.x ; i++) {
		vec2 coords = st - vec2(i) * texel * dir;
		vec4 tcol = texture2D(Front, coords);
		i += 1;

		for (int j = 1 ; j < length ; j++) {
			coords = st - vec2(j) * texel * dir;
			col = texture2D(Front, coords);

			i += 1;

			float tave = adsk_getLuminance(tcol.rgb);
			float ave = adsk_getLuminance(col.rgb);

			if (col == tcol) {
				continue;
			}

			if (ave > tave) {
				col = tcol;
			}
		}
	}

	gl_FragColor = col;
}
