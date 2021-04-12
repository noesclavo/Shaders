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
uniform sampler2D Back;
uniform int rings;
uniform float speed;
uniform float times_len;

void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy * texel;

    vec3 front = texture2D(Front, st).rgb;
    vec3 back = texture2D(Back, st).rgb;

    vec2 p = 2.0 * st - vec2(1);
    p.x *= adsk_result_frameratio;

    float r = sqrt(pow(p.x, 2) + pow(p.y, 2));
    float theta = atan(p.y/p.x);
    r += adsk_time * -speed * .01 / rings;

    float matte = sin(r * float(rings) * PI);
    matte = ( matte + .5 ) * .66666666666666666666;
    matte = mix(0.0, 1.0, matte);

    if (matte < 0.0) {
        matte = clamp(-1.0, 0.0, matte *= PI);
    }

    vec3 outcol = mix(back, front, clamp(0.0, 1.0, matte));

    gl_FragColor = vec4(outcol, matte);
}
