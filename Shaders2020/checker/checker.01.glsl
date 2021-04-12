#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

vec3  adsk_hsv2rgb( vec3 hsv );

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform float size;
uniform vec3 color1;
uniform vec3 color2;
uniform float aspect;
uniform bool bg_color;

vec3 getRGB( float hue, float sat) {
    vec3 rgb =  adsk_hsv2rgb( vec3( hue, sat, 1.0 ) );

    rgb = clamp(rgb, 0.0, 1.0);

    return rgb;
}


void main(void) {
    vec2 st = gl_FragCoord.xy / res;
    vec4 outcol = vec4(0.0);

    vec3 col1 = getRGB( color1.x / 360.0, color1.y * .01 ) * vec3(color1.z * .01);
    vec3 col2 = getRGB( color2.x / 360.0, color2.y * .01 ) * vec3(color2.z * .01);

    col1 = color1;
    col2 = color2;

    if (! bg_color) {
        col2 = vec3(0.0);
    }

    st = st * vec2(2.0) - vec2(1.0);
    st *= vec2(size *.5 * ratio / aspect, size *.5);

    float h_block = floor(st.x);
    float v_block = floor(st.y);

    if (mod(v_block, 2.0) == 0.0) {
        if (mod(h_block, 2) == 0) {
            outcol = vec4(col1, 1.0);
        } else {
            outcol.rgb = col2;
        }
    } else {
        if (mod(h_block, 2) == 0) {
            outcol.rgb = col2;
        } else {
            outcol = vec4(col1, 1.0);
        }
    }

    gl_FragColor = outcol;
}
