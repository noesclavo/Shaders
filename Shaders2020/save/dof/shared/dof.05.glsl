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

uniform sampler2D adsk_results_pass4;

void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy * texel;

    vec4 front = texture2D(adsk_results_pass4, st);

    gl_FragColor = front;
}
