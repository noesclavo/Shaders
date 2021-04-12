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

uniform sampler2D Left;
uniform sampler2D Right;

void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy * texel;

    vec4 black = vec4(0.0);

    st -= vec2(.5);
    st *= 2.0;
    st += vec2(.5);

    st += vec2(.5, 0.0);
    vec4 left = texture2D(Left, st);
    if (any(notEqual(clamp(vec2(0.0), vec2(1.0), st), st))) {
        left = black;
    }
    st -= vec2(.5, 0.0);


    st -= vec2(.5, 0.0);
    vec4 right = texture2D(Right, st);
    if (any(notEqual(clamp(vec2(0.0), vec2(1.0), st), st))) {
        right = black;
    }

    gl_FragColor = left + right;
}
