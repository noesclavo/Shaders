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
uniform float target;
uniform float compress;
uniform float expand;

void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy * texel;

    vec3 front = texture2D(Front, st).rgb;
	vec3 outcol = vec3(1.0) - distance(vec3(target), front);
	outcol = pow(outcol, vec3(compress));
	outcol = clamp(outcol, 0.0, 1.0);
	outcol *= expand;
	outcol = clamp(outcol, 0.0, 1.0);
	

    gl_FragColor.rgb = outcol;
}
