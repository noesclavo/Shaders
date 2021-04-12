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
uniform float thresh;
uniform float oof;


void main(void) {
    vec2 st = gl_FragCoord.xy / res;
    vec3 outcol = vec3(0.0);

    float front = texture2D(Front, st).r;
    float front2 = texture2D(Front, st + vec2(oof) * texel).r;
    if (abs(front - front2) > thresh) {
        outcol.r = 1.0;
    }

    gl_FragColor.rgb = outcol;
}
