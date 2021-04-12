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

uniform sampler2D Front;
uniform sampler2D Back;
uniform sampler2D Matte;


void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec3 front = texture2D(Front, st).rgb;
	vec3 back = texture2D(Back, st).rgb;
	float matte = texture2D(Matte, st).r;

	mat3 rgb2yuv = mat3(
		.2126, .7152, .0722,
		-.09991, -.33609, .436,
		.615, -.55861, -.05639
	);

	mat3 yuv2rgb = mat3(
		1,	0.0,	1.28033,
		1, -.21482, -.38059,
		1, 2.12798, 0
	);

	front *= rgb2yuv;
	back *= rgb2yuv;

	vec3 comp = back;
	comp.gb = mix(back.gb, front.gb, matte);

	comp *= yuv2rgb;

	gl_FragColor.rgb = comp;
}
