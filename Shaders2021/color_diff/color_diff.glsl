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
uniform sampler2D Incolor;
uniform vec3 col;
uniform bool use_incolor;

void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy * texel;

    vec3 front = texture2D(Front, st).rgb;
    vec3 incolor = texture2D(Incolor, st).rgb;

    vec3 outcol = abs(front - col);
    if (use_incolor) {
         outcol = abs(front - incolor);
    }

    float total = outcol.r + outcol.g + outcol.b;

    if (total > 0.01) {
        outcol.rgb = vec3(1.0);
    }

    outcol = vec3(1.0) - outcol;

    gl_FragColor.rgb = outcol;
}
