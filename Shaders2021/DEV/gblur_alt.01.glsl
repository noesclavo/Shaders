#version 120

#define ratio adsk_result_frameratio

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform float sigma;
vec2 dir = vec2(1.0, 0.0);

float offset[3] = float[]( 0.0, 1.3846153846, 3.2307692308 );
float weight[3] = float[]( 0.2270270270, 0.3162162162, 0.0702702703 );

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec3 front = texture2D(Front, st).rgb;
	float pass = 0;

	for (int i = 0; i < sigma; i++) {
		front += texture2D(Front, st + vec2(i) * texel * dir).rgb * weight[1];
		front += texture2D(Front, st - vec2(i) * texel * dir).rgb * weight[1];

		pass += 2.0;
	}

	front /= pass;

	gl_FragColor.rgb = front;
}
