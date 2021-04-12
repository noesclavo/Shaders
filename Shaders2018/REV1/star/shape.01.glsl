#version 120

vec3 adsk_hsv2rgb( in vec3 src );

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

uniform sampler2D Front;
uniform float r;
uniform int sides;
uniform float deform;

uniform vec3 tint;

vec3 getRGB( float hue, float sat)
{
    vec3 rgb =  adsk_hsv2rgb( vec3( hue, sat, 1.0 ) );

    rgb = clamp(rgb, 0.0, 1.0);

    return rgb;
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;
  st = st * vec2(2.0) - vec2(1.0);
  st.x *= adsk_result_frameratio;

  vec4 col = vec4(0.0);
  float d = length(abs(st) - .5);
  d = length(max(abs(st) - vec2(.3), 0.0));

  vec4 outcol = vec4(fract(d * 4));
  outcol = vec4(step(.3, d));
  outcol = vec4(smoothstep(.3, .4, d) * smoothstep(.6, .5, d));

	//shape

	st /= .5;
  float a = atan(st.x, st.y) + PI;
  float r = 2 * PI / float(sides);

  d = cos(floor(.5 + a / r) * r - a) * length(st - vec2(0, deform));
  outcol = vec4(1.0 - smoothstep(.2, .21, d));

	vec3 g_offset = getRGB( tint.x / 360.0, tint.y * .01 ) * vec3( tint.z * 0.05);
	outcol.rgb *= g_offset;

	gl_FragColor = vec4(outcol.rgb, 0);
}
