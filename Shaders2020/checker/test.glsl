#version 120

#define PI 3.1415926535897932

float adsk_getLuminance( vec3 );

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform vec3 color;
uniform float sat;

void main(void) {
    vec3 cc = clamp(color, 0.0, 10.0);
    vec3 cw = vec3(adsk_getLuminance(cc));
    vec3 c = mix(cw, cc, sat);
    gl_FragColor.rgb = c;
}
