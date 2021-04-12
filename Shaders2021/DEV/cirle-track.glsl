#version 120

#define PI 3.1415926535897932
#define fratio adsk_result_frameratio
#define pratio adsk_result_pixelratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform vec2 cam_pos;
uniform vec2 pivot;
uniform float swing;
uniform float cam_pos_x;


vec2 rotate_coords(vec2 coords, float r)
{
	float rot = radians(r);

	mat2 rm = mat2(
		cos(rot), sin(rot),
		-sin(rot), cos(rot)
	);

	//coords -= vec2(.5);
	//coords.x *= adsk_result_frameratio;
	coords *= rm;
	//coords.x /= adsk_result_frameratio;
	//coords += vec2(.5);

	return coords;
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;
	vec2 center = vec2(.5);
	float rad = .25;
	float arm_length = .1;

	vec3 outcol = vec3(0.);

	vec3 red = vec3(1., 0., 0.);
	vec3 green = vec3(0., 1., 0.);
	vec3 blue = vec3(0., 0., 1.);

	vec2 p = vec2(cos(adsk_time/10), sin(adsk_time/10)) * rotate_coords(vec2(rad), 0);

	vec2 av = vec2(arm_length) * p;
	av -= p;
	vec2 a = rotate_coords(av, swing);
	a += p;

	st -= vec2(.5);
	st.x *= adsk_result_frameratio;
	float dist = abs(length(st - p));
	float pivot = 1.0 - smoothstep(.01, .015, dist);
	outcol = mix(outcol, green, pivot);

	dist = abs(length(st - a));
	float camera = 1.0 - smoothstep(.01, .015, dist);
	outcol = mix(outcol, red, camera);

	gl_FragColor.rgb = outcol;
}
