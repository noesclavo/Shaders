#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

float adsk_getLuminance(vec3 color);

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform float t;

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec4 color = texture2D(Front, st);
	float lum = adsk_getLuminance(color.rgb);
	int pass = 1;

	for (int i = 1; i <= lum * res.x * .5; i++) {
		vec2 coords = st - vec2(i) * vec2(1.0, 0.0) * texel;
		if (coords.x < 0.0 || coords.x > 1) {
			continue;
		}
		color += texture2D(Front, st - vec2(i) * vec2(1.0, 0) * texel);
		pass++;
	}

	color /= pass;

	gl_FragColor = color;
}
