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
uniform sampler2D Normals;
uniform float blue;


void main(void) {
    vec2 st = gl_FragCoord.xy / res;

    vec3 front = texture2D(Front, st).rgb;
    vec3 normals = texture2D(Normals, st).rgb;

    float d = abs(1.0 - normals.b);

    d = smoothstep(blue, 1.0, d);

    gl_FragColor = vec4(d);
}
