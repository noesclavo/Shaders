#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

vec3  adsk_hsv2rgb( vec3 hsv );

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform vec3 ca;
uniform vec3 cb;
uniform vec3 cc;
uniform vec3 cd;

vec2 CosSin(float x) {
	vec2 si = fract(vec2(0.5,1.0) - x*2.0)*2.0 - 1.0;
	vec2 so = sign(0.5-fract(vec2(0.25,0.5) - x));
	return (20.0 / (si*si + 4.0) - 4.0) * so;
}

vec3 color(float x, vec3 a, vec3 b, vec3 c, vec3 d) {
	return a + b + cos(2.0 * PI * (c * x + d));
}

vec3 getRGB( float hue, float sat)
{
    vec3 rgb =  adsk_hsv2rgb( vec3( hue, sat, 1.0 ) );

    rgb = clamp(rgb, 0.0, 1.0);

    return rgb;
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec3 a = getRGB( ca.x / 360.0, ca.y * .01) * vec3(ca.z * .01);
	vec3 b = getRGB( cb.x / 360.0, cb.z * .001 ) * vec3( cb.y * 0.05);
	vec3 c = getRGB( cc.x / 360.0, cc.z * .001 ) * vec3( cc.y * 0.05);
	vec3 d = getRGB( cd.x / 360.0, cd.z * .001 ) * vec3( cd.y * 0.05);

	vec3 col = vec3(0.0);

	col = color(st.x, a, b, c, d);

	gl_FragColor.rgb = col;
}
