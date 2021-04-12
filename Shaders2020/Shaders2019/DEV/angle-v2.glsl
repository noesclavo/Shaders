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

vec2 center = vec2(.5);
uniform vec2 p;

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

    vec2 p1 = normalize(center - vec2(1.0, .5));
    vec2 p2 = normalize(center - st);
    float theta = acos(dot(p1, p2));

    if (st.y < .5) {
        //theta = PI + (PI - theta);
    }

    vec4 c = vec4(theta / (2.0 * PI));
    //c = vec4(theta);
    c = vec4(degrees(theta));


	gl_FragColor = c;
}
