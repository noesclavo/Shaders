#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

float adsk_getLuminance(vec3 src);

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D adsk_results_pass1;
uniform sampler2D Front;
uniform float width;

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec3 front = texture2D(Front, st).rgb;
	vec4 incol = texture2D(adsk_results_pass1, st);
	vec4 b = incol;
	int pass = 1;

	vec2 coords = st * vec2(2.0) - vec2(1.0);

	for (int i = 1; i < width; i++) {
		vec4 col = texture2D(adsk_results_pass1, st - vec2(i, 0.0) * texel);

		float l = adsk_getLuminance(col.rgb);

		 if (l == .00) {
			 continue;
		 }

	 	b += col;
	 	pass += 1;
	}

	b /= max(pass, .000000001);

	float xxx = fract(st.y * res.y * .25);
	b *= vec4(xxx * 2);
	b.a = step(.1, b.a);

	gl_FragColor = vec4(b.rgb, incol.a);
	gl_FragColor = b;
}
