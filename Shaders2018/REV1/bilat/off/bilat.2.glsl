#version 120

uniform float ratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D adsk_results_pass1;
uniform sampler2D Matte;


void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec3 front = texture2D(adsk_results_pass1, st).rgb;
	float matte = texture2D(Matte, st).r;

	gl_FragColor = vec4(front * matte, matte);
}
