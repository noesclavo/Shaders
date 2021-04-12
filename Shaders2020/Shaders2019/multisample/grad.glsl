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
uniform vec2 left, right;


void main(void) {
    vec2 st = gl_FragCoord.xy / res;

    vec3 col1 = texture2D(Front, left).rgb;
    vec3 col2 = texture2D(Front, right).rgb;

    vec2 l = left;
    vec2 r = right;


    vec2 a = -l * (1.0 - st.x) + r * st.x; 
    vec3 grad1 = mix(col1, col2, a.x);
    if (l.x > r.x) {
        a = -r * (1.0 - st.x) + l * st.x; 
        grad1 = mix(col2, col1, a.x);
    }

    vec3 grad2 = mix(col1, col2, a.y);

    vec3 grad = grad1;

    gl_FragColor.rgb = grad;
}
