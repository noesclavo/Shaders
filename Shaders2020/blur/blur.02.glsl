#version 120

#define PI 3.14159
#define center vec2(.5)

uniform int adsk_result_execution;
uniform float adsk_result_pixelratio;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

uniform sampler2D adsk_results_pass1;
uniform sampler2D adsk_results_pass2;
uniform sampler2D Strength;
uniform float blur_amount;
uniform int repeat;

uniform float h_bias;
uniform float v_bias;

vec2 repeat_coords(vec2 coords) {
    //tile
    if (repeat == 1) {
        if (coords.x > 1.0 || coords.x < 0.0) {
            coords.x = fract(coords.x);
        }
        if (coords.y > 1.0 || coords.y < 0.0) {
            coords.y = fract(coords.y);
        }
    //mirror
    } else if (repeat == 2) {
        if (mod(floor(coords.x), 2) != 0) {
            coords.x = 1.0 - fract(coords.x);
        } else {
            coords.x = fract(coords.x);
        }
        if (mod(floor(coords.y), 2) != 0.0) {
            coords.y = 1.0 - fract(coords.y);
        } else {
            coords.y = fract(coords.y);
        }
    } else if (repeat == 3) {
        if (coords.x > 1.0 || coords.x < 0.0) {
            discard;
        }
        if (coords.y > 1.0 || coords.y < 0.0) {
            discard;
        }
    }

    return coords;
}


void main(void) {
    vec2 uv = gl_FragCoord.xy;

    float bias = h_bias;
    vec2 dir = vec2(1.0, 0.0);

    if (adsk_result_execution == 1) {
        bias = v_bias * adsk_result_pixelratio;;
        dir = vec2(0.0, 1.0);
    }

    float strength = 1.0;

    if (adsk_result_execution == 0) {
        strength = abs(texture2D(Strength, uv * texel).r);
    } else {
        strength = abs(texture2D(Strength, uv * texel).g);
    }

    strength = mix(strength, 1.0, abs(texture2D(Strength, uv * texel).b));

    dir *= sign(strength);
    strength = abs(strength);

    //http://http.developer.nvidia.com/GPUGems3/gpugems3_ch40.html
    float sigma = blur_amount * bias * strength;
    sigma = max(sigma, 0.0001);

    float g0 = 1.0 / (sqrt(2.0 * PI) * sigma);
    float g1 = exp(-0.5 / (sigma * sigma));
    float g2 = g1 * g1;

    vec2 st = uv * texel;

    vec4 blurred = vec4(0.0);
    if (adsk_result_execution == 0) {
        blurred += g0 * texture2D(adsk_results_pass1, st);
    } else {
        blurred += g0 * texture2D(adsk_results_pass2, st);
    }

    float pass = g0;
    g0 *= g1;
    g1 *= g2;

    for(float i = 1; i <= sigma * 3.0; i++) {
        st = (uv - i * dir) * texel;
        st = repeat_coords(st);

        if (adsk_result_execution == 0) {
            blurred += g0 * texture2D(adsk_results_pass1, st);
            pass += g0;
        } else {
            blurred += g0 * texture2D(adsk_results_pass2, st);
            pass += g0;
        }

        st = (uv + i * dir) * texel;
        st = repeat_coords(st);

        if (adsk_result_execution == 0) {
            blurred += g0 * texture2D(adsk_results_pass1, st);
            pass += g0;
        } else {
            blurred += g0 * texture2D(adsk_results_pass2, st);
            pass += g0;
        }

        g0 *= g1;
        g1 *= g2;
    }

    blurred /= pass;

    gl_FragColor = blurred;
}
