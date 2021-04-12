#version 120
#extension GL_ARB_shader_texture_lod : enable

#define ratio adsk_result_frameratio
#define luma(col) dot(col, vec3(0.2126, 0.7152, 0.0722))
#define PI 3.141592653589793238462643383279502884197969
#define INPUT1 Strength
#define INPUT2 Depth

uniform float ratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D INPUT1;
uniform sampler2D INPUT2;
uniform bool ignore_depth;

float adsk_mergeHalvesInFloat(vec3 h);

void main(void) {
	vec2 st = gl_FragCoord.xy / res;
	float depth = .5;

	vec3 strength = texture2D(INPUT1, st).rgb;

	if (! ignore_depth) {
		vec3 packedDepth = texture2D(INPUT2,st).rgb;
		depth = adsk_mergeHalvesInFloat(packedDepth);
	}

	gl_FragColor = vec4(strength, depth);
}
