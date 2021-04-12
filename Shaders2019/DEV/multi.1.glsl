#version 120

#define PI 3.1415926535897932
#define fratio adsk_result_frameratio
#define pratio adsk_result_pixelratio

uniform int adsk_result_execution;
uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform sampler2D adsk_results_pass1;

vec3 col(sampler2D tex, vec2 coords) {
    vec3 color = texture2D(tex, coords).rgb;
    return color;
}


void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy * texel;

    vec3 color = col(Front, st);

    if (adsk_result_execution == 1) {
        if (st.y > .5) {
            color = col(adsk_results_pass1, vec2(1.0) - st);
        }
    }

    gl_FragColor.rgb = color;
}
