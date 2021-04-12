#version 120
#extension GL_ARB_shader_texture_lod : enable

vec4 adsk_getBlendedValue( int blendType, vec4 srcColor, vec4 dstColor );
float adsk_getLuminance( vec3 );

uniform sampler2D Front;
uniform sampler2D adsk_accum_texture;
uniform float adsk_result_w, adsk_result_h;
uniform sampler2D adsk_previous_frame_Front, adsk_next_frame_Front;
uniform float adsk_time;
uniform bool adsk_accum_no_prev_frame;
uniform float mix_val;

void main()
{
    vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
    vec4 front = texture2D(Front, st);

    vec4 previous = vec4(0.0);
    vec4 next = vec4(0.0);
    vec4 col = vec4(0.0);

    if (adsk_accum_no_prev_frame) {
      col = front;
      col.a = adsk_getLuminance(front.rgb);
    } else {
      previous = texture2D(adsk_accum_texture, st);

      col = mix(front, previous, mix_val);
    }

    gl_FragColor = col;
}
