#version 120

#define PI 3.1415926535897932

#define ratio adsk_result_frameratio
#define FrontPremult adsk_results_pass1

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Strength;
uniform sampler2D FrontPremult;

uniform int repeat;
uniform vec2 center;
uniform float rotation;
uniform vec2 scale;
uniform vec2 shear;
uniform float uniform_scale;
uniform vec2 translate;
uniform bool strength_is_pos;
uniform bool show_strength;

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

vec2 rotate_coords(vec2 coords, float r)
{
    float rot = radians(r);

    mat2 rm = mat2(
        cos(rot), sin(rot),
        -sin(rot), cos(rot)
    );

    coords -= center;
    coords.x *= ratio;
    coords *= rm;
    coords.x /= ratio;
    coords += center;

    return coords;
}

vec2 scale_coords(vec2 coords, vec2 scale) {
    coords -= center;
    coords /= scale;
    coords += center;

    return coords;
}

vec2 shear_coords(vec2 coords, vec2 shear) {
    coords -= center;

    mat2 sm = mat2(
        1.0, shear.x * texel.x,
        shear.y * texel.y, 1.0
    );

    coords *= sm;
    coords += center;

    return coords;
}

vec2 translate_coords(vec2 coords, vec2 t) {
    //coords -= t * texel * vec2(.5);
    coords -= t * texel;

    return coords;
}

void main(void) {
    vec2 st = gl_FragCoord.xy / res;
    vec2 coords = st;

    vec2 strength = texture2D(Strength, st).rg;
    vec2 strength_norm = (strength * texel + vec2(1.0) ) * vec2(.5);
    float strength_ave = (strength.x + strength.y) * .5;

    vec4 warped = vec4(0.0);

    vec2 scale_val = scale * vec2(.01) * (uniform_scale * .01);

    float strength_angle = atan(strength_norm.g - center.y, strength_norm.r - center.x);
    if (strength_angle < 0) {
        strength_angle += 2.0 * PI;
        strength_angle = (strength_angle);
    }

    if (strength.x == strength.y) {
        strength_angle = strength_ave;
    }

    coords = rotate_coords(coords, rotation * strength_angle);
    coords = scale_coords(coords, mix(vec2(1.0), scale_val, (strength)));
    coords = shear_coords(coords, shear * vec2(strength));
    coords = translate_coords(coords, translate * (strength));

    coords = repeat_coords(coords);

    warped = texture2D(FrontPremult, coords);

    gl_FragColor = warped;
}
