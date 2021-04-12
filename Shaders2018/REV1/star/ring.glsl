#version 120

#define PI 3.1415926535897932
#define fratio adsk_result_frameratio
#define pratio adsk_result_pixelratio

vec3 adsk_hsv2rgb( in vec3 src );

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform float thickness;
uniform float softness;
uniform vec3 tint;
uniform float gap;
uniform float gain;

vec3 getRGB( float hue, float sat)
{
    vec3 rgb =  adsk_hsv2rgb( vec3( hue, sat, 1.0 ) );

    rgb = clamp(rgb, 0.0, 1.0);

    return rgb;
}


void main(void) {
	vec2 st = gl_FragCoord.xy / res;
	vec2 c = vec2(.5);

	st.x *= adsk_result_frameratio;
	c.x *= adsk_result_frameratio;


	float angle = acos(dot(normalize(st - c), normalize(vec2(c.x, 1) - c)));
	angle = (PI - angle) * gap * .01;
	float cutout = 1.0 - smoothstep(.25, .3, angle);

	float s = softness * .01;
	float outer = smoothstep(.2 + thickness * .01, .2 + thickness * .01 + s, length(st -c));
	float inner = smoothstep(.2 + (thickness - 1) * .01, .2 + (thickness - 1) * .01 + s, length(st -c));
	float ring = abs(smoothstep(.2 + angle, .2 + angle + s, length(st - c)) - outer);
	float ring2 = abs(smoothstep(.2 + angle, .2 + angle + s, length(st - c)) - inner);
	ring *= 1.0 - smoothstep(.2 + (thickness - 1) * .01, .2 + (thickness - 1) * .01 + s, length(st -c));

	ring *= cutout;

	vec3 g_offset = getRGB( tint.x / 360.0, tint.y * .01 ) * vec3( tint.z * 0.05);
	vec3 outcol = vec3(ring) * g_offset;

	outcol = mix(outcol, outcol * gain, pow(ring2, 2.0));

	gl_FragColor.rgb = outcol;
	gl_FragColor.a = ring;
}
