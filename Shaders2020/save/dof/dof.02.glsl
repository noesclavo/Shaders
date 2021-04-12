//Pick or analyze depth and return blur matte

#version 120

#define ratio adsk_result_frameratio
#define pr adsk_result_pixelratio
#define PI 3.141592653589793238462643383279502884197969

float adsk_getLuminance( in vec3 color );
float adsk_highlights( in float pixel, in float halfPoint );

uniform float ratio, pr;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Depth;

uniform float far;
uniform float aperture;
uniform float focal_distance;
uniform float focal_length;
uniform vec2 depth_pick;
uniform bool pick_depth;

void main(void) {
    vec2 st = gl_FragCoord.xy / res;

    float depth = texture2D(Depth, st).r;
    depth = clamp(depth, 0.0, 1.0);

    //focal distance: where in the gray scale depth input should stay in focus.
    float fp = focal_distance;

    if (pick_depth) {
        fp = texture2D(Depth, depth_pick).r;
    }

    float blur_factor;

    //bigger the aperture the more the blur
    blur_factor = distance(fp, depth) * aperture;
    blur_factor = clamp(blur_factor, 0.0, 1.0);

    if (focal_length > 0.0) {
        blur_factor = pow(blur_factor, focal_length);
    }

    gl_FragColor = vec4(blur_factor);
}
