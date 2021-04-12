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

//uniform vec2 cam_pos;
//uniform vec2 pivot;

uniform float theta;
uniform vec2 base;
uniform float arm_length;

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	/*
	vec2 center = vec2(0.5); // center of track
	vec2 nodal = center;
	vec2 nodal_point = normalize(nodal - pivot);
	vec2 cam_point = normalize(nodal - cam_pos);

	float swing_angle = acos(dot(nodal_point, cam_point) / (length(nodal_point) * length(cam_point)));
	*/


	st = st * vec2(2.0) - vec2(1.0);
	vec2 p = base;
	float b = 1.0 - smoothstep(.01, .02, length(st - base));

	float arm = arm_length;
	float r = radians(theta);

	vec2 x = vec2(cos(r) * arm + p.x, sin(r) * arm + p.y);

	vec3 cam = vec3(x, 0);
	float dist = length(st - x);
	dist = 1.0 - smoothstep(.01, .02, dist);
	float center = 1.0 - smoothstep(.01, .02, length(st - vec2(0.)));

	dist += center + b;;

	gl_FragColor.rgb = mix(cam, vec3(1.0), dist);
}
