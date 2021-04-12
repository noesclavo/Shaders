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

uniform sampler2D adsk_results_pass1;
uniform float chroma;

void main(void) {
    vec2 st = gl_FragCoord.xy / res;

    float c = chroma * .01;
    vec4 outcol = vec4(0.0);
    vec4 refractions =  texture2D(adsk_results_pass1, st);

    outcol.r = texture2D(adsk_results_pass1, st + vec2(c, 0)).r;
    outcol.g = texture2D(adsk_results_pass1, st + vec2(0, c)).g;
    outcol.b = texture2D(adsk_results_pass1, st + vec2(-c, 0)).b;
    outcol.a = refractions.a;

    outcol = mix(refractions, outcol, refractions.a);

    gl_FragColor = outcol;
}
