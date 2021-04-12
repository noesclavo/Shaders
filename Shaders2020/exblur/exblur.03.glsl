#version 120

#define PI 3.141592653

#define VERTICAL

#define PreMult adsk_results_pass2
uniform sampler2D PreMult;
uniform sampler2D Strength;


uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
uniform int repeat;

vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;


uniform bool matte_is_strength;

uniform float blur_amount;
uniform float blur_red;
uniform float blur_green;
uniform float blur_blue;
float blur_matte = 1.0;

#ifdef VERTICAL
    uniform float v_bias;
    float bias = v_bias * adsk_result_pixelratio;
    vec2 dir = vec2(0.0, 1.0);
#else
    uniform float h_bias;
    float bias = h_bias;
    vec2 dir = vec2(1.0, 0.0);
#endif


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


vec4 blur()
{
    vec2 uv = gl_FragCoord.xy;

    float strength = texture2D(Strength, uv * texel).r;

    //Optional texture used to weight amount of blur

    float br = blur_red * blur_amount * bias * strength;
    float bg = blur_green * blur_amount * bias * strength;
    float bb = blur_blue * blur_amount * bias * strength;
    float bm = blur_matte * blur_amount * bias * strength;


    //http://http.developer.nvidia.com/GPUGems3/gpugems3_ch40.html
    float s = max(br, max(bg, bb));
    vec4 sigma = vec4(br, bg, bb, bm);
    sigma = max(sigma, 0.0001);

    vec4 g0 = 1.0 / (sqrt(2.0 * PI) * sigma);
    vec4 g1 = exp(-0.5 / (sigma * sigma));
    vec4 g2 = g1 * g1;

    vec2 st = uv * texel;

    vec4 blurred = g0 * texture2D(PreMult, st);
    vec4 pass = g0;
    g0 *= g1;
    g1 *= g2;

    float support = max(max(sigma.r, sigma.g), sigma.b);

    for(float i = 1; i <= support * 3.0; i++) {
        st = (uv - i * dir) * texel;
        st = repeat_coords(st);

        blurred += g0 * texture2D(PreMult, st);

        st = (uv + i * dir) * texel;
        st = repeat_coords(st);

        blurred += g0 * texture2D(PreMult, st);
        pass += g0 * 2.0;

        g0 *= g1;
        g1 *= g2;
    }

    blurred /= pass;

    return blurred;
}

void main(void) {
    gl_FragColor = blur();
}
