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

uniform float y_rot;

vec2 rotate_coords(vec2 coords, float r)
{
    float rot = radians(r);

    mat2 rm = mat2(
        cos(rot), sin(rot),
        -sin(rot), cos(rot)
    );

    coords *= rm;

    return coords;
}

void main(void) {
    vec2 st = gl_FragCoord.xy / res;

    vec3 front = texture2D(Front, st).rgb;
    vec3 cmy = vec3(1.0) - front;

    float y = -.379395;

    mat3 rgb2yuv = mat3(
        .2126, .7152, .0722,
        -.09991, -.33609, .436,
        .615, -.55861, -.05639
    );

    mat3 yuv2rgb = mat3(
        1,  0.0,    1.28033,
        1, -.21482, -.38059,
        1, 2.12798, 0
    );

    front *= rgb2yuv;
    float uv_ave = front.g + front.b;
    float d = distance(uv_ave, y);

    front = vec3(d);




    gl_FragColor.rgb = front;
}
