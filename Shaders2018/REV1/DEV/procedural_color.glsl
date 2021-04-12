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
uniform vec3 cc;

uniform int i;

vec2 CosSin(float x) {
	vec2 si = fract(vec2(0.5,1.0) - x*2.0)*2.0 - 1.0;
	vec2 so = sign(0.5-fract(vec2(0.25,0.5) - x));
	return (20.0 / (si*si + 4.0) - 4.0) * so;
}

float rand(vec2 coords) {
	return fract(CosSin(dot(coords.xy, vec2(12.989 + mod(adsk_time, 10.0), 78.233))) * 43758.5453).r;
}

vec3 getRGB( float hue, float sat)
{
    vec3 rgb =  adsk_hsv2rgb( vec3( hue, sat, 1.0 ) );

    rgb = clamp(rgb, 0.0, 1.0);

    return rgb;
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec3 col = vec3(0.);

	float a_matte = 1.0 - step(.25, st.x);
	float b_matte = 1.0 - step(.5, st.x);
	float c_matte = 1.0 - step(.75, st.x);
	float d_matte = 1.0;

	a_matte = clamp(1.0 - distance(st.x, .0) * 3, 0.0, 1.0);
	b_matte = clamp(1.0 - distance(st.x, .33) * 3, 0.0, 1.0) * (1.0 - a_matte);
	d_matte = clamp(1.0 - distance(st.x, 1.0) * 3, 0.0, 1.0);
	c_matte = clamp(1.0 - distance(st.x, .666) * 3, 0.0, 1.0) * (1.0 - d_matte);

	vec3 col_a = getRGB( ca.x / 360.0, ca.y * .01) * vec3(ca.z * .01);
	vec3 col_c = getRGB( cc.x / 360.0, ca.y * .01) * vec3(cc.z * .01);

	col = mix(vec3(1.0) - col_c, col_c, c_matte);
	col = mix(col, vec3(1.0) - col_a, b_matte);
	col = mix(col, col_a, a_matte);

	col *= vec3(st.y);

	float m[] = float[](a_matte, b_matte, c_matte, d_matte);


	gl_FragColor = vec4(col, m[i]);
}
