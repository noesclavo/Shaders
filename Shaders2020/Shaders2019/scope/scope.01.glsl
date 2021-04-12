#version 120

#define PI 3.141592653589793238462643383279502884197969
#define center vec2(.5)

float adsk_getLuminance( in vec3 color );

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform int sample_density;
uniform int scope;

//uniform float gain;
//uniform float depth;

//For mx_def to work, shaders must have the naming convention of: shader_name.01.glsl, shader_name.02.glsl, etc ..
//Even if the shader only contains 1 pass

//:scale:vec2(1.0)
//:uscale:1.0
//:invert:true


vec3 comp3 (vec3 color, vec3 test, vec3 yes, vec3 no, int op) {
	vec3 retval = no;

	// Equal to
	if (op == 0) {
		if (color.r == test.r) {
			retval.r = yes.r;
		}

		if (color.g == test.g) {
			retval.g = yes.g;
		}

		if (color.b == test.b) {
			retval.b = yes.b;
		}
	// Less than
	} else if (op == 1) {
		if (color.r < test.r) {
			retval.r = yes.r;
		}

		if (color.g < test.g) {
			retval.g = yes.g;
		}

		if (color.b < test.b) {
			retval.b = yes.b;
		}
	// Greater than
	} else if (op == 2) {
		if (color.r > test.r) {
			retval.r = yes.r;
		}

		if (color.g > test.g) {
			retval.g = yes.g;
		}

		if (color.b > test.b) {
			retval.b = yes.b;
		}
	}

	return retval;
}

void main(void) {
	vec2 uv = gl_FragCoord.xy;

	vec3 front = vec3(0.0);
	vec3 outcol = vec3(0.0);
	float alpha = 0.0;

	for (float j = 0; j < res.y; j += max(1.0, float(sample_density))) {
		float x = uv.x - .5;
		float y = uv.y + 1.5;

		front = texture2D(Front, vec2(x, j) * texel).rgb;
		float front_luma = adsk_getLuminance(front);

		if (scope == 1) {
			front = vec3(0.0, front_luma, 0.0);
		}

		vec3 color_val = front * vec3(res.y);
		vec3 val = ceil(color_val);

		val = comp3(fract(color_val), vec3(.5), floor(color_val), val, 1);
		outcol = comp3(val, vec3(y), vec3(.9), outcol, 0);
	}

	if (adsk_getLuminance(outcol) > .1) {
		alpha = 1.0;
	}

	outcol = clamp(outcol, 0.0, .8);

	gl_FragColor = vec4(outcol, alpha);
}
