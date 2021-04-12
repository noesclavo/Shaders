#version 120

#define PI 3.1415926535897932

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D adsk_results_pass1;
uniform sampler2D Front;
uniform bool show_turbulence;
uniform float rotation_factor;
uniform float scale_factor;

#define repeat 1
#define center vec2(.5)
#define ratio adsk_result_frameratio

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

vec2 scale_coords(vec2 coords, float s) {
    coords.x *= ratio;
    coords /= s;
    coords.x /= ratio;

    return coords;
}

vec2 rotate_coords(vec2 coords, float r) {
    float rot = radians(r);

    mat2 rm = mat2(
        cos(rot), sin(rot),
        -sin(rot), cos(rot)
    );

    coords.x *= ratio;
    coords *= rm;
    coords.x /= ratio;

    return coords;
}

vec2 translate_coords(vec2 coords, vec2 t) {
    coords -= t;

    return coords;
}

void main(void) {
    vec2 st = gl_FragCoord.xy / res;

    vec2 p = vec2(adsk_time) * texel;
    vec3 turb = texture2D(adsk_results_pass1, p).rgb;

    vec2 uv = st;
    vec3 front = vec3(0.0);

    float zoom = mix(1.0, turb.b, scale_factor);
    float roll = turb.b * rotation_factor;
    
    uv = scale_coords(uv, zoom);
    uv = rotate_coords(uv, roll);
    uv = translate_coords(uv, turb.rg);

    front += texture2D(Front, uv).rgb;

    if (show_turbulence) {
        st = repeat_coords(st);
        front = texture2D(adsk_results_pass1, st).rgb;
    }

    gl_FragColor.rgb = front;
}
