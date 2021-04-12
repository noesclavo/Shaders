#version 120

#define PI 3.141592653589793238462643383279502884197969
#define Scope adsk_results_pass1

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Scope;
uniform sampler2D Front;
uniform int scope;
uniform float front_mix;

//For mx_def to work, shaders must have the naming convention of: shader_name.01.glsl, shader_name.02.glsl, etc ..
//Even if the shader only contains 1 pass

//:scale:vec2(1.0)
//:uscale:1.0
//:invert:true

#define center vec2(.5);


void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec4 outcol = vec4(0.0);

	if (scope == 2) {
		vec2 x_scale = st;

		x_scale.x = st.x / .33333;

		if (x_scale.x < 1.0) {
			outcol.r = texture2D(Scope, x_scale).r;
		}

		x_scale.x = (st.x - .33333) / .33333;

		if (x_scale.x > 0.0 && x_scale.x < 1.0) {
			outcol.g = texture2D(Scope, x_scale).g;
		}

		x_scale.x = (st.x - .33333 * 2.0) / .3333;

		if (x_scale.x > 0.0 && x_scale.x < 1.0) {
			outcol.b = texture2D(Scope, x_scale).b;
		}

		outcol.a = clamp(outcol.r + outcol.g + outcol.b, 0.0, 1.0);
	} else {
		outcol = texture2D(Scope, st);
	}

	if (front_mix > 0.0) {
		vec3 front = texture2D(Front, st).rgb;
		outcol.rgb = mix(outcol.rgb, front, front_mix * (1.0 - outcol.a));
	}

	gl_FragColor = outcol;
}
