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
uniform sampler2D Matte;
uniform sampler2D UVs;


void main(void) {
    vec2 st = gl_FragCoord.xy / res;

    vec2 uvs = texture2D(UVs, st).rg;
    vec3 front = texture2D(Front, uvs).rgb;
    float matte = texture2D(Matte, uvs).r;

    gl_FragColor = vec4(front, matte);
}
