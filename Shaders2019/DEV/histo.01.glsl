#version 120

#define ratio adsk_result_frameratio

float adsk_getLuminance( in vec3 color );
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform float white;
uniform float falloff;

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec3 front = texture2D(Front, st).rgb;
	float luma = adsk_getLuminance(front);

	float c = clamp(luma, 0.0, white);
	float c_gain = 1 / white * c;
	float c_contrast = (c_gain - 1.0) * (1.0 / falloff) + 1.0;

	vec4 outcol = vec4(c_contrast);

	/*
	if (c_contrast <= 0.0) {
		outcol.rgb = vec3(1.0, 0.0, 0.0);
	}
	*/

	gl_FragColor = outcol;
}
