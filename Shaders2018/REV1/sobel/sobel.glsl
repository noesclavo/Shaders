#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform int width;

vec3 convolve(vec2 dir) {
	vec2 st = gl_FragCoord.xy / res;

	vec3 g = vec3(0.0);

	dir.y *= adsk_result_frameratio;

	for (int j = 0; j <= 1; j++) {
		for (int i = -1; i <= 1; i++) {
			float mult = 2.0 - abs(float(i));
			if (j == 0) {
				dir = vec2(-1) * dir;
				vec2 odir = abs(dir - dir);
				vec2 coords = st - ((odir * vec2(i) + dir) * texel);
				g -= texture2D(Front, coords).rgb * vec3(mult);
			} else {
				vec2 odir = abs(dir - dir);
				vec2 coords = st - ((odir * vec2(i) + dir) * texel);
				g += texture2D(Front, coords).rgb * vec3(mult);
			}
		}
	}

	return g;
}

void main(void) {

	vec3 X = vec3(0.0);
	vec3 Y = vec3(0.0);

	for (int i = 0; i <= width; i++) {
		X += convolve(vec2(0.0, i));
		Y += convolve(vec2(i, 0.0));
	}

	vec3 edge = sqrt(X * X + Y * Y);

	gl_FragColor.rgb = edge;
}
