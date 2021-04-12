#version 120

#define PI 3.141592653589793238462643383279502884197969
#define Strength adsk_results_pass3

float adsk_getLuminance( in vec3 color );

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform sampler2D adsk_results_pass1;
uniform sampler2D Strength;

uniform vec2 center;
uniform float uniform_scale;
uniform vec2 scale;
uniform float rotate;
uniform vec2 pos;
uniform vec2 shear;
uniform float scale_vectors;

uniform bool strength_are_vectors;
uniform bool show_vectors;
uniform bool warped_only;
uniform bool clip_matte_with_strength;

//For mx_def to work, shaders must have the naming convention of: shader_name.01.glsl, shader_name.02.glsl, etc ..
//Even if the shader only contains 1 pass

//:scale:vec2(1.0)
//:uscale:1.0
//:invert:true

vec2 translate_uv(vec2 coords, vec2 position) {
	coords -= position;

	return coords;
}

vec2 rotate_uv(vec2 coords, vec2 angle) {
	vec2 rad = radians(angle);

	mat2 rm = mat2(
		cos(rad.x), sin(rad.x),
		-sin(rad.y), cos(rad.y)
	);

	coords -= center;
	coords.x *= adsk_result_frameratio;
	coords *= rm;
	coords.x /= adsk_result_frameratio;
	coords += center;

	return coords;
}

vec2 scale_uv(vec2 coords, vec2 scale_val) {
	coords -= center;
	coords /= scale_val;
	coords += center;

	return coords;
}

vec2 shear_uv(vec2 coords, vec2 shear_val)
{
	mat2 sm = mat2(
		1.0, shear_val.x,
		shear_val.y, 1.0
	);

	coords -= center;
	coords *= sm;
	coords += center;

	return coords;
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec3 strength = texture2D(Strength, st).rgb;
	vec3 front = texture2D(Front, st).rgb;

	float os = clamp(adsk_getLuminance(strength), 0.0, 1.0);
	strength *= vec3(scale_vectors);

	vec2 coords = st;

	vec2 scale_val = vec2(uniform_scale) * scale;
	scale_val = mix(vec2(1.0), scale_val, strength.rg);

	coords = shear_uv(coords, shear * strength.rg);
	coords = scale_uv(coords, scale_val);
	coords = rotate_uv(coords, rotate * strength.rg);
	coords = translate_uv(coords, pos * strength.rg);

	vec4 outcol = texture2D(adsk_results_pass1, coords);

	if (clip_matte_with_strength) {
		outcol *= vec4(os);
	}

	if (strength_are_vectors && show_vectors) {
		outcol.rgb = strength;
	}

	if (! warped_only) {
		outcol.rgb = mix(front, outcol.rgb / max(outcol.a, .00001), outcol.a);
	}

	gl_FragColor = outcol;
}
