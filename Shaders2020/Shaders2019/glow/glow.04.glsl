#version 120

#define PI 3.141592653

uniform int adsk_result_execution;

vec4 adsk_getBlendedValue( int blendType, vec4 srcColor, vec4 dstColor );
vec3 adsk_scene2log( in vec3 src );
vec3 adsk_log2scene( in vec3 src );

uniform float adsk_result_pixelratio;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

uniform sampler2D adsk_results_pass1;
uniform sampler2D adsk_results_pass2;
uniform sampler2D adsk_results_pass3;
uniform sampler2D adsk_results_pass4;
uniform sampler2D Strength;             // Strength / Selective
uniform int repeat;

uniform float blur_amount;
uniform float blur_red;
uniform float blur_green;
uniform float blur_blue;
uniform float blur_matte;

uniform float h_bias;
uniform float v_bias;

uniform bool is_premult;
uniform bool lat;

uniform int outcol;
uniform float exp_ave;

uniform int passes;

vec2 repeat_coords(vec2 coords) {
    //repeat value of 0 is default
    //default is stretch

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
    //crop
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

vec4 blur(sampler2D tex, float eblur, bool e) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy / res;
    vec2 strength = texture2D(Strength, st).rg;


    float bias = e ? h_bias * strength.r : v_bias * strength.g * adsk_result_pixelratio;
    vec2  dir = e ? vec2(1.0, 0.0) : vec2(0.0, 1.0);

    float br = blur_red * eblur * bias;
    float bg = blur_green * eblur * bias;
    float bb = blur_blue * eblur * bias;

    //http://http.developer.nvidia.com/GPUGems3/gpugems3_ch40.html
    float s = max(br, max(bg, bb));
    float bm = s;
    vec4 sigma = vec4(br, bg, bb, bm);
    sigma = max(sigma, 0.0001);

    vec4 g0 = 1.0 / (sqrt(2.0 * PI) * sigma);
    vec4 g1 = exp(-0.5 / (sigma * sigma));
    vec4 g2 = g1 * g1;

    vec4 blurred = g0 * texture2D(tex, st);

    vec4 pass = g0;
    g0 *= g1;
    g1 *= g2;

    float support = max(max(sigma.r, sigma.g), sigma.b);

    for(float i = 1; i <= support * 3.0; i++) {
        st = (xy - i * dir) * texel;
        st = repeat_coords(st);
        blurred += g0 * texture2D(tex, st);

        st = (xy + i * dir) * texel;
        st = repeat_coords(st);
        blurred += g0 * texture2D(tex, st);

        pass += g0 * 2.0;
        g0 *= g1;
        g1 *= g2;
    }

    blurred /= pass;

    return blurred;
}

vec4 ave(vec4 tex1, vec4 tex2) {
    return (tex1 + tex2) * exp_ave;
}

void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy / res;

    bool e = mod(float(adsk_result_execution), 2.0) == 0.0 ? true : false;

    float eblur = blur_amount;

    if (eblur > 0.0) {
        //eblur = pow(max(eblur, .000001), 3);
    }

    eblur = pow(eblur, 3.0);

    vec4 blurred = vec4(0.0);

    if (passes == 1) {
        discard;
    } else if (adsk_result_execution == 0) {
        blurred = blur(adsk_results_pass3, eblur, e);
    } else if (adsk_result_execution == 1) {
        blurred = blur(adsk_results_pass4, eblur, e);
    }

    gl_FragColor = blurred;

}

