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

uniform float g;
void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	//st = st * 2.0 - 1.0;
	float pos_x = st.x * 8;
	float x = floor(pos_x);
	x = 1.0 - mod(x, 2.);
	pos_x = fract(pos_x);
	pos_x = pow(pos_x, g);
	if (x == 0) {
		pos_x = 1.0 - fract(pos_x);
	}

	pos_x *= g;



	float d = smoothstep(0, 1, pos_x);

	float dots = 0.0;
	vec2 t = vec2(0.);

	t.x = adsk_time / 100.;
	t.y = pos_x * .1;
	t.y += .5;

	st.x *= adsk_result_frameratio;
	t.x *= adsk_result_frameratio;

	float dist = length(st - t);
	dots += 1.0 - smoothstep(.01, .011, dist);

	vec4 outcol = vec4(dots);




	gl_FragColor = outcol;
}
