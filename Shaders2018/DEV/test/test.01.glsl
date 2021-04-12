#version 120

#define PI 3.141592653589793238462643383279502884197969
#define center vec2(.5);

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;

//For mx_def to work, shaders must have the naming convention of: shader_name.01.glsl, shader_name.02.glsl, etc ..
//Even if the shader only contains 1 pass

//:scale:vec2(1.0)
//:uscale:1.0
//:invert:true



void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec3 front = texture2D(Front, st).rgb;

	front.rg = gl_FragCoord.xy;


	gl_FragColor.rgb = front;
}
