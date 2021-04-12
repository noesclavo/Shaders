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

uniform float angle;

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

    vec2 p1 = normalize(vec2(.5) - vec2(1, .5));
    vec2 p2 = normalize(vec2(.5) - st);

    float a = acos(dot(p1, p2));

    if (st.y < .5) {
        a = PI + (PI - a);
    }

    if (a != 0.0) {
        a /= 2.0 * PI;
    }

    float a1 = fract(angle);
    float outcol = 1.0 - smoothstep(a1, a1 + texel.x * 2, a);

	gl_FragColor = vec4(outcol, outcol, outcol, 0.0);
}
