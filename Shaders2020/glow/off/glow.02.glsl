#version 120

#define PI 3.141592653
#define epass 1

uniform int adsk_result_execution;

vec3 adsk_scene2log( in vec3 src );
vec3 adsk_log2scene( in vec3 src );

uniform float adsk_result_pixelratio;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

uniform sampler2D adsk_results_pass1;   // Premultiplied Input
uniform sampler2D adsk_results_pass2;   // Output of horizontal blur execution pass (the first pass);;             
uniform sampler2D Strength;             // Strength / Selective
uniform int repeat;

uniform float width;
uniform float red_weight;
uniform float green_weight;
uniform float blue_weight;

uniform float horizontal_bias;
uniform float vertical_bias;

uniform int expo_passes;

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

    float bias = e ? horizontal_bias * strength.r : vertical_bias * strength.g * adsk_result_pixelratio;
    vec2  dir = e ? vec2(1.0, 0.0) : vec2(0.0, 1.0);

    float br = red_weight * eblur * bias;
    float bg = green_weight * eblur * bias;
    float bb = blue_weight * eblur * bias;

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

void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy / res;

    bool e = mod(float(adsk_result_execution), 2.0) == 0.0 ? true : false;
    float eblur = pow(width, epass);

    if (e) {
        gl_FragColor = blur(adsk_results_pass1, eblur, e);
    } else {
        gl_FragColor = blur(adsk_results_pass2, eblur, e);
    }
}

