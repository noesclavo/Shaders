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
uniform sampler2D Matte;

uniform int number;
uniform float softness;
uniform float diameter;
uniform float x_offset;
uniform float y_offset;
uniform float scale;
uniform float mixx;

void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy * texel;
    vec2 uv = st * vec2(2.0) - vec2(1.0);

    vec3 front = texture2D(Front, st).rgb;
    vec3 back = texture2D(Back, st).rgb;
    float matte = texture2D(Matte, st).r;

    uv.x *= adsk_result_frameratio;

    uv /= scale;
    uv -= vec2(x_offset, y_offset) * texel;
    uv *= float(number) * .25;
    uv = fract(uv);

    float r = diameter * adsk_result_frameratio * texel.x;
    float s = softness * adsk_result_frameratio * texel.x;

    float circle = distance(uv, vec2(0.5));
    circle = 1.0 - smoothstep(r, r + s, circle);

    float transparency = ( (100.0 - mixx) * .01 ) * matte;
    vec4 outcol = vec4(circle);
    outcol.rgb = mix(back, front, circle * transparency);
   
    outcol.a = transparency;


    gl_FragColor = outcol;
}
