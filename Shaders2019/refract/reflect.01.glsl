#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform sampler2D Matte;
uniform sampler2D Norm;
uniform sampler2D POS;
uniform sampler2D Reflection;

uniform int repeat;

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
    }

    return coords;
}


/*
vec2 transform_coords(vec2 coords) {
    vec2 scale_vec = vec2(scale_x, scale_y) * vec2(scale);
    vec2 position_vec = vec2(position_x, position_y);

    coords -= center;
    coords /= scale_vec;
    coords += center;

    coords -= position_vec * vec2(.1);

    return coords;
}
*/

void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = gl_FragCoord.xy / res;

    vec4 front = texture2D(Front, st);
    float matte = texture2D(Matte, st).r;
    vec3 normals = texture2D(Norm, st).rgb;
    vec3 poss_pass = texture2D(POS, st).rgb;

    // convert position to shader coord system
    poss_pass /= vec3(res, poss_pass.z); //absolute to -1 -> 1
    poss_pass = (poss_pass + vec3(1.0)) * vec3(.5); // -1 -> 1 to 0 -> 1

    normals = normalize(normals);
    vec3 camera = vec3(.5, .5, -1);
    vec3 ray = normalize(poss_pass - camera);
    vec3 inc = ray - 2 * dot(ray, normals) * normals;

    vec3 reflection_vector = reflect(ray, normals);
    reflection_vector.rg = repeat_coords(st + reflection_vector.rg);
    vec4 reflection = texture2D(Front, reflection_vector.rg);

    vec4 outcol = vec4(0.0);
    outcol.rgb = reflection.rgb;

    gl_FragColor = outcol;
}
