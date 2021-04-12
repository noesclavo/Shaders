#version 120

#define fratio adsk_result_frameratio
#define pratio adsk_result_pixelratio

const float PI = 3.1415926535897932;

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform sampler2D Matte;

void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy * texel;

    vec3 front = texture2D(Front, st).rgb;
    float matte = texture2D(Matte, st).r;

    vec4 outcol = vec4(front, matte);

    gl_FragColor = outcol;
}
