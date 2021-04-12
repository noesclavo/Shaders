#version 120

#define PI 3.1415926535897932
#define fratio adsk_result_frameratio
#define pratio adsk_result_pixelratio

vec3  adskEvalDynCurves( ivec3 curve, vec3 x );

float adsk_getLuminance ( vec3 rgb );

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform ivec3 c;

uniform float red_gain;
uniform float green_gain;
uniform float blue_gain;
uniform float scale;


float rand(vec2 n) {
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p){
	vec2 ip = floor(p);
	vec2 u = fract(p);
	u = u*u*(3.0-2.0*u);

	float res = mix(
		mix(rand(ip),rand(ip+vec2(1.0,0.0)),u.x),
		mix(rand(ip+vec2(0.0,1.0)),rand(ip+vec2(1.0,1.0)),u.x),u.y);
	return res*res;
}

void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy * texel * vec2(1.0, pratio);;

    /*
    vec3 front = texture2D(Front, st).rgb;

    float grain_r = noise(st);
    float grain_g = noise(st);
    float grain_b = noise(st);

    vec3 grain = vec3(grain_r, grain_g, grain_b);

    vec3 l = adskEvalDynCurves(c, front);

    front = mix(front, front + grain, l);
    */

    vec3 front = vec3(noise(st/scale * .01));

    gl_FragColor.rgb = front;
}
