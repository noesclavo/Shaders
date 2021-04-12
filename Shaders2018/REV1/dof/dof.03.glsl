//create highlight matte and apply gain to FG through it
#version 120

#define ratio adsk_result_frameratio
#define pr adsk_result_pixelratio
#define PI 3.141592653589793238462643383279502884197969

float adsk_getLuminance( in vec3 color );

uniform float ratio, pr;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D adsk_results_pass1;
uniform sampler2D adsk_results_pass2;

uniform float highlight_falloff;
uniform float gain;
uniform float threshold;
uniform bool show_threshold;

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec4 front = texture2D(adsk_results_pass1, st);
	float blur_factor = texture2D(adsk_results_pass2, st).a;

	float luma = adsk_getLuminance(front.rgb);

	//create highlight matte based on threshold, falloff and blur_matte
	float w = smoothstep(threshold, threshold + .25, luma);
	float highlight_matte = (w * blur_factor) * (highlight_falloff * 10);
	highlight_matte = clamp(highlight_matte, 0.0, 1.0);

	vec3 front_cc = front.rgb * vec3(mix(1.0, gain, blur_factor));

	front.rgb = mix(front.rgb, front_cc, highlight_matte);

	float matte = front.a;

	if (show_threshold) {
		matte = highlight_matte;
	}

	gl_FragColor = vec4(front.rgb, matte);
}
