#version 120
#extension GL_ARB_shader_texture_lod : enable

float adsk_getLuminance( vec3 );

uniform sampler2D Front;
uniform sampler2D adsk_results_pass1;
uniform float adsk_result_w, adsk_result_h;
uniform float adsk_time;
uniform float lod;
uniform bool auto_gain;

void main()
{
    vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
    vec4 front = texture2D(Front, st);
    vec4 front_avg = texture2DLod(Front, st, 10);
    vec4 accum = texture2D(adsk_results_pass1, st);
    vec4 accum_ave = texture2DLod(adsk_results_pass1, st, 10);

    vec4 gain = front_avg / accum_ave;

    //accum *= gain;
    accum.a = adsk_getLuminance(abs(accum.rgb - front.rgb));

    if (auto_gain) {
      accum /= adsk_time;
    }

    gl_FragColor = accum;
}
