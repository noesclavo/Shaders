#version 120

#define PI 3.1415926535897932
#define fratio adsk_result_frameratio
#define pratio adsk_result_pixelratio

float adsk_shadows( in float pixel, in float halfPoint );
float adsk_getLuminance( in vec3 color );
float adsk_highlights( in float pixel, in float halfPoint );



uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform float half_point;


void main(void) {
    vec2 st = gl_FragCoord.xy / res;
    vec3 front = texture2D(Front, st).rgb;

    float luma = adsk_getLuminance(front);
    float shad = adsk_highlights(luma, half_point);
    float high = adsk_shadows(luma, half_point);

    front = vec3(abs(shad - high));
    front = vec3(shad);
    if (st.y > .5) {
        front = vec3(high);
    }

    front = vec3(high * shad * 4.0);



    gl_FragColor.rgb = front;
}
