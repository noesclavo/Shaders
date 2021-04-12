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


const float a1 = .5;
const float a2 = .3750;
const float a3 = .31250;
const float a4 = .21694214876033057851;

float acosine(float num) {
    flout n = num +
              a1 * (pow(num, 3) / 3) +
              a2 * (pow(num, 5) / 5) +
              a3 * (pow(num, 7) / 7) +
              a4 * (pow(num, 9) / 9);

    return n
}


void main(void) {
	vec2 st = gl_FragCoord.xy / res;

    vec2 p1 = normalize(vec2(.5) - vec2(1, .5));
    vec2 p2 = normalize(vec2(.5) - st);

    float a = acosine(dot(p1, p2));

	gl_FragColor.rgb = mix(cam, vec3(1.0), dist);
}
