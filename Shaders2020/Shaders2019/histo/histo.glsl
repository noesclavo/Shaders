#version 120

#define PI 3.1415926535897932
#define fratio adsk_result_frameratio
#define pratio adsk_result_pixelratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
float adsk_getLuminance( in vec3 color );
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform vec3 black;
uniform vec3 mid;
uniform vec3 white;
uniform int matte_out;


void main(void) {
    vec2 st = gl_FragCoord.xy / res;

    vec3 front = texture2D(Front, st).rgb;
    vec3 lo = (front - vec3(1.0)) * black + vec3(1.0);
    vec3 mids = (front - vec3(.5)) * mid + vec3(.5);
    vec3 hi = front * white;

    vec4 outcol = vec4(front, 0.0);

    outcol.rgb = (lo + hi + mids) * vec3(.33333333333333333333333333333333);
    float matte = adsk_getLuminance(outcol.rgb);
    outcol.a = matte;

    if (matte_out == 1) {
        outcol.a = outcol.r;
    } else if (matte_out == 2) {
        outcol.a = outcol.g;
    } else if (matte_out == 3) {
        outcol.a = outcol.b;
    }


    gl_FragColor = outcol;
}
