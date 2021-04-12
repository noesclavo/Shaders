#version 120
  
#define PI 3.1415926535897932
#define fratio adsk_result_frameratio
#define pratio adsk_result_pixelratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Normals;
uniform vec3 rotation;

vec3 rotate_coords(vec3 coords, vec3 rot) {
    mat3 rmx = mat3(
        1.0, 0.0, 0.0,
        0.0, cos(rot.x), sin(rot.x),
        0.0, -sin(rot.x), cos(rot.x)
    );

    mat3 rmy = mat3(
        cos(rot.y), 0.0, sin(rot.y),
        0.0, 1.0, 0.0,
        -sin(rot.y), 0.0, cos(rot.y)
    );

    mat3 rmz = mat3(
        cos(rot.z), sin(rot.z), 0.0,
        -sin(rot.z), cos(rot.z), 0.0,
        0.0, 0.0, 1.0
    );

    coords *= rmx;
    coords *= rmy;
    coords *= rmz;

    return coords;
}

void main(void) {
    vec2 st = gl_FragCoord.xy / res;

    vec3 normals = texture2D(Normals, st).rgb;
    normals = rotate_coords(normals, rotation);

    gl_FragColor.rgb = normals;
}



