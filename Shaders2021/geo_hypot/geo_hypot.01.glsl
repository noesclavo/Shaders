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
uniform sampler2D Back;
uniform sampler2D Matte;

uniform float mixx;
uniform int blend_mode;

void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy * texel;

    vec3 front = texture2D(Front, st).rgb;
    vec3 back = texture2D(Back, st).rgb;
    float matte = texture2D(Matte, st).r;

    vec4 outcol = vec4(0.0);
    outcol.a = matte;

    if (blend_mode == 0) {
        outcol.rgb = sqrt(pow(front, vec3(2)) + pow(back, vec3(2)));
    } else {
        outcol.rgb = vec3(2.0) * front * back / (front + back);
    }

    float alpha = 100.0 - mixx;

    outcol.rgb = mix(back, outcol.rgb, matte * (alpha * .01));


    gl_FragColor = outcol;
}
