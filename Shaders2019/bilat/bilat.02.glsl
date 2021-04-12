#version 120

#define luma(col) dot(col, vec3(0.2126, 0.7152, 0.0722))
#define PI 3.141592653589793238462643383279502884197969

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

#define max_detail 11

uniform sampler2D Front;
uniform sampler2D adsk_results_pass1;
uniform int samples;
uniform float amount;
uniform int detail;

float normpdf(float x, float sigma) {
    return .39894 * exp(-.5 * x * x / (sigma * sigma)) / sigma;
}

float normpdf3(vec3 v, float sigma) {
    return .39894 * exp(-.5 * dot(v, v) / (sigma * sigma)) / sigma;
}

void main(void) {
    vec2 st = gl_FragCoord.xy / res;

    vec4 front = texture2D(Front, st);

    int kernel_size = (samples - 1) / 2;
    float kernel[100];

    for (int i = 0 ; i <= kernel_size; ++i) {
        kernel[kernel_size + i] = kernel[kernel_size - i] = normpdf(float(i), amount);
    }

    float bsigma = (max_detail - detail) * .01;
    vec4 outcol = vec4(0.0);
    vec4 cc = vec4(0.0);
    float factor;
    float Z = 0.0;
    float bZ = 1.0 / normpdf(0.0, bsigma);

    for (int i = -kernel_size ; i <= kernel_size; ++i) {
        for (int j = -kernel_size ; j <= kernel_size; ++j) {
            cc = texture2D(adsk_results_pass1, st + vec2(float(i), float(j)) * texel);
            factor = normpdf3(cc.rgb - front.rgb, bsigma) * bZ * kernel[kernel_size + j] * kernel[kernel_size + i];
            Z += factor;
            outcol += factor * cc;
        }
    }

    outcol /= Z;
    outcol.a = clamp(outcol.a, 0.0, 1.0);

    gl_FragColor = outcol;
}
