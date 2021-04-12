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

uniform int op;
uniform bool invert_matte;
uniform bool invert_op;


void main(void) {
    vec2 st = gl_FragCoord.xy / res;

    vec3 front = texture2D(Front, st).rgb;
    float matte = texture2D(Matte, st).r;

    matte = clamp(matte, 0.0, 1.0);

    vec4 outcol = vec4(0.0);

    float o = op;
    if (invert_op) {
        o = 1.0 - o;
    }

    if (invert_matte) {
        matte = 1.0 - matte;
    }

    if (o == 1) {
        if (matte > 0.0) {
            outcol.rgb = front / vec3(matte);
        }
    } else {
        outcol.rgb = front * vec3(matte);
    }

    outcol.a = matte;

    gl_FragColor = outcol;
}
