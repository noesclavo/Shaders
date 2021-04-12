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
uniform bool clamp_output;

vec3 getRGB( float hue, float sat)
{
    vec3 rgb =  adsk_hsv2rgb( vec3( hue, sat, 1.0 ) );

    rgb = clamp(rgb, 0.0, 1.0);

    return rgb;
}


void main(void) {
	vec2 st = gl_FragCoord.xy / res;
	vec2 c = vec2(.5);

    float ring = .5;
    float max_width = .5;

	st.x *= adsk_result_frameratio;
	c.x *= adsk_result_frameratio;

    float dist = 1.0 - distance(c, st) * 2.0;

	float angle = acos(dot(normalize(st - c), normalize(c - vec2(c.x, 1))));
    float cutout = clamp(angle * gap, 0.0, 1.0);
    cutout = smoothstep(.5, 1.0, cutout);

	float s = 1.0 / softness;
    float t = thickness * .1 * (1.0 - cutout);

    float outer = smoothstep(max_width, max_width + .01 * softness, dist);
    float inner = smoothstep(max_width * t, (max_width + .01 * softness) * t, dist);

    ring = mix(outer, 0.0, inner) * (1.0 - cutout);

	vec3 g_offset = getRGB( tint.x / 360.0, tint.y * .01 ) * vec3( tint.z * 0.05);
	vec3 outcol = vec3(ring) * g_offset;

	outcol = mix(outcol, outcol * gain, ring);

    if (clamp_output) {
        outcol = clamp(outcol, 0.0, 1.0);
    }

	gl_FragColor.rgb = outcol;
	gl_FragColor.a = ring;
}
