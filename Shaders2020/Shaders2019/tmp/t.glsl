#version 120

#define ratio adsk_result_frameratio
#define pr adsk_result_pixelratio
#define PI 3.141592653589793238462643383279502884197969
#define min_fstops 2.0
#define max_fstops 5.6

float adsk_getLuminance( in vec3 color );
float adsk_highlights( in float pixel, in float halfPoint );

uniform float ratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform sampler2D adsk_results_pass1;
uniform sampler2D adsk_results_pass2;
uniform sampler2D adsk_results_pass3;
uniform int sides;
uniform float fstops;
uniform int samples;
uniform float width;
uniform float aspect;
uniform float rotate;
uniform bool show_kernel;
uniform bool clamp_output;
//uniform bool show_threshold;
uniform float shutter_angle;

uniform float noise_amount;
uniform float noise_size;
uniform float seed;

float noise_a = noise_amount + 1.0;

uniform int make_depth;
uniform int grad_center;
uniform vec2 grad_1;
uniform vec2 grad_2;

vec2 CosSin(float x) {
    vec2 si = fract(vec2(0.5,1.0) - x*2.0)*2.0 - 1.0;
    vec2 so = sign(0.5-fract(vec2(0.25,0.5) - x));
    return (20.0 / (si*si + 4.0) - 4.0) * so;
}

float rand(vec2 coords, float seed) {
    return fract(CosSin(dot(coords.xy, vec2(12.989 + mod(seed, 10.0), 78.233))) * 43758.5453).r;
}


vec2 to_concentric(vec2 coords) {
    float phi;
    float r;

    float a = 2.0 * coords.x - 1.0;
    float b = 2.0 * coords.y - 1.0;
    vec2 ret = vec2(0.0);

    if (a * a > b * b) {
        // same thing as .. if (abs(a) > abs(b)) {
        // a > .0000001
        // keeps us from dividing by zero
        if (abs(a) > 1e-8) {
            r = a;
            phi = (PI / 4) * (b / a);
            ret = vec2(phi, r);
        } else {
            ret = vec2(0.0, a);
        }
    } else {
        // b > .0000001
        if (abs(b) > 1e-8) {
            r = b;
            phi = (PI / 2 ) - (PI / 4 ) * (a / b);
            ret = vec2(phi, r);
        } else {
            ret = vec2(0.0, b);
        }
    }

    float noise_x = rand(ret, 1);
    float noise_y = rand(ret, 2);
    return mix(vec2(noise_x, noise_y), ret, 0.95 + noise_a*0.05);
}


void main(void) {
    vec2 st = gl_FragCoord.xy / res;
    st = to_concentric(st);

    vec4 color = texture2D(Front, st);

    gl_FragColor = color;
}
