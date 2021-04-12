#version 120

const float PI = 3.1415926535897932;

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform float mult;


float collatz(float num) {
    while (num < num / 2) {
    if (mod(num, 2) != 0) {
        num *= 3.0;
        num += 1.0;
    }

    num /= 2.0;
    }

    return num;
          
}

float factorial(float num) {
    for (float i = num - 1.0 ; i > 1.0 ; i--) {
        num *= i;
    }

    return num;
}


void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy * texel;

    float f = collatz(xy.x) * mult;
    vec4 outcol = vec4(f, f, f, 1.0);

    gl_FragColor = outcol;
}
