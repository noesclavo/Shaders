#version 120

#define PI 3.141592653589793238462643383279502884197969
#define LinearFront adsk_results_pass1
#define center vec2(.5)
#define dir vec2(1.0, 0.0)

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D LinearFront;
uniform float blur_amount;
uniform float rot;

void main(void) {
	vec2 uv = gl_FragCoord.xy;
	vec2 st = gl_FragCoord.xy / res;

	vec4 blur = texture2D(LinearFront, st);
	int pass = 1;

	for (float i = 1; i < blur_amount; i++) {
		vec2 dist = vec2(i) * texel;

		blur += texture2D(LinearFront, st + dist * dir);
		blur += texture2D(LinearFront, st - dist * dir);

		pass += 2;
	}

	blur /= pass;

	gl_FragColor = blur;
}
