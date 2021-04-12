#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform bool show_lines;
uniform bool show_safe;
uniform int num;
uniform int guide_pos;
uniform float p;

#define line_col vec3(1.0, 0, 0)

float lines() {
	float x = gl_FragCoord.x - .5;
	float y = gl_FragCoord.y - .5;

	float percent = float(p / 100);

	if (x > res.x * p) {
		return 0;
	}

	if (mod(y, 2.0) == 0) {
		return 0.0;
	}

	return .5;
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;
	float x = gl_FragCoord.x - .5;
	float y = gl_FragCoord.y - .5;

	vec3 front = texture2D(Front, st).rgb;
	vec3 outcol = front;

	if (show_lines) {
		float m = lines();
		outcol = mix(outcol, line_col, m);
	}

	if (y == float(guide_pos) || y == float(guide_pos + num + 1)) {
		outcol = vec3(1.0);
	}

	if (y > float(guide_pos) && y < float(guide_pos + num + 1)) {
		outcol = mix(outcol, vec3(0.0, .6, 8.0), .3);
	}

	if (show_safe) {
		float four_three_size = res.x / 1.333;
		float four_three = ceil((res.x - four_three_size) * .5);
		float four_three_action = four_three_size * .05;
		float four_three_title = four_three_size * .1;
		vec2 action = res * .05;
		vec2 title = res * .1;

		if (x == four_three || x == res.x - four_three) {
			outcol = vec3(0.0);
		}

		if (y >= action.y && y <= res.y - action.y) {
			if (x ==  ceil(four_three + four_three_action) || x == res.x - ceil(four_three + four_three_action)) {
				outcol = vec3(1.0, 00, 0.0);
			}
		}

		if (y >= title.y && y <= res.y - title.y) {
			if (x ==  ceil(four_three + four_three_title) || x == res.x - ceil(four_three + four_three_title)) {
				outcol = vec3(0.0, 1.0, 0.0);
			}
		}

		if (x >= action.x && y >= action.y && x <= res.x - action.x && y <= res.y - action.y) {
			if (x == action.x || x == res.x - action.x || y == action.y || y == res.y - action.y) {
				outcol = vec3(1.0, .0, 0.0);
			}
		}

		if (x >= title.x && y >= title.y && x <= res.x - title.x && y <= res.y - title.y) {
			if (x == title.x || x == res.x - title.x || y == title.y || y == res.y - title.y) {
				outcol = vec3(0.0, 1.0, 0.0);
			}
		}
	}

	gl_FragColor = vec4(outcol, front.r);
}
