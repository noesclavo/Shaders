#version 120

vec3 adsk_hsv2rgb( in vec3 src );

#define PI 3.1415926535897932
#define fratio adsk_result_frameratio
#define pratio adsk_result_pixelratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform float g;
uniform float stretch;
uniform float rotate;
uniform float gain;
uniform int repeat;

uniform vec3 tint;

vec3 getRGB( float hue, float sat)
{
    vec3 rgb =  adsk_hsv2rgb( vec3( hue, sat, 1.0 ) );

    rgb = clamp(rgb, 0.0, 1.0);

    return rgb;
}


vec2 rotate_coords(vec2 coords, float r)
{
	float rot = radians(r);

	mat2 rm = mat2(
		cos(rot), sin(rot),
		-sin(rot), cos(rot)
	);

	coords -= vec2(.5);
	coords.x *= adsk_result_frameratio;
	coords *= rm;
	coords.x /= adsk_result_frameratio;
	coords += vec2(.5);

	return coords;
}

vec2 scale_coords(vec2 coords) {
	//coords -= vec2(.5);
    coords /= vec2(stretch);
	//coords += vec2(.5);

    return coords;
}


void main(void) {
	vec2 st = gl_FragCoord.xy / res;
	vec2 center = vec2(0.5);

	float t = adsk_time;
    if (t >= 1000.) {
        t = fract(adsk_time / 1000.) * 1000.;
    } else if (t >= 100) {
        t = fract(adsk_time / 100.) * 100.;
    }

    t = adsk_time  * .01;

	vec3 g_offset = getRGB( tint.x / 360.0, tint.y * .01 ) * vec3( tint.z * 0.05);

    st = rotate_coords(st, rotate);

	vec2 fpos = st * 2 - 1;
    fpos *= 4;
    float dist_y = 1.0 - distance(fpos.y, 0.0);
    float dist_x = 1.0 - distance(scale_coords(fpos).x, 0.0);

    if (dist_x < 0) {
        dist_x = 0.0;
    }

    float spike = pow(dist_y, 100 - g - 50);

    spike *= dist_x;
    spike *= spike * gain;
    spike *= spike;

    spike = clamp(spike, 0.0, 1.0);

	vec3 outcol = vec3(spike) * g_offset;

	gl_FragColor = vec4(outcol, spike);
}
