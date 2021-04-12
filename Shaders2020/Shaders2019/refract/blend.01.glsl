#version 120

#define PI 3.1415926535897932
#define fratio adsk_result_frameratio
#define pratio adsk_result_pixelratio

vec4 adsk_getBlendedValue( int blendType, vec4 srcColor, vec4 dstColor );

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform sampler2D Back;
uniform sampler2D Matte;
uniform int op;
uniform float mmix;

#define geometry 2.0 * front * back / (front + back)
#define hypot sqrt(front * front + back * back)
#define average (front + back) * .5
#define screen adsk_getBlendedValue(17, front, back)

void main(void) {
    vec2 st = gl_FragCoord.xy / res;

    vec4 front = texture2D(Front, st);
    vec4 back = texture2D(Back, st);
    float matte = texture2D(Matte, st).r;

    vec4 ops[4] = vec4[](geometry, hypot, average, screen);

    vec4 comp = ops[op];

    comp.rgb = mix(back.rgb, comp.rgb, mmix * matte);
    comp.a = matte;

    gl_FragColor = comp;
}
