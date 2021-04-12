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

uniform sampler2D Front;

uniform float value;
uniform vec2 pick;
uniform float falloff;
uniform bool picker;

void main(void) {
    vec2 st = gl_FragCoord.xy / res;
	float front = texture2D(Front, st).r;

	float c = value;
	if (picker) {
		c = texture2D(Front, pick).r;
	}

	float dif = 1.0 - abs(front - c);
	dif = mix(dif, 1.0, falloff);

    dif = clamp(dif, 0.0, 1.0);
	

	vec4 color = vec4(dif);


    gl_FragColor = color;
}
