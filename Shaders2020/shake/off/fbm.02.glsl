#version 120
#extension GL_ARB_shader_texture_lod : enable

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
uniform sampler2D adsk_results_pass2;

uniform int lod;

uniform bool show_shake;


void main(void) {
    vec2 st = gl_FragCoord.xy / res;

    vec4 front = texture2D(Front, st);

    if (show_shake) {
        vec4 shake = texture2D(adsk_results_pass1, st);
        for (int i = 0 ; i < lod ; i++) {
            adsk_result_execution == 0 ? shake += texture2D(adsk_results_pass1, st + vec2(i) * vec2(1.0, 0.0) * texel) :
                shake += texture2D(adsk_results_pass2, st - vec2(i) * vec2(0.0, 1.0) * texel);

            adsk_result_execution == 0 ? shake += texture2D(adsk_results_pass1, st + vec2(i) * vec2(1.0, 0.0) * texel) :
                shake += texture2D(adsk_results_pass2, st + vec2(i) * vec2(0.0, 1.0) * texel);
        }
        
        shake /= lod * 2.0;
        front = shake;
    }

    

    gl_FragColor = front;
}
