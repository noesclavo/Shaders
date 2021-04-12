#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform int bs;

void main(void) {
	vec2 st = gl_FragCoord.xy / res;
	vec2 uv = st;


	//convert to -1 to 1
	uv = uv * vec2(2.0) - vec2(1.0);

	uv.x *= adsk_result_frameratio;

	//bs = 960 ... 1920 / 960 = 2 blocks
	float block_size = res.x / bs;
	//separate into block 0 and block 1
	vec2 current_block = floor(uv * vec2(block_size));
	//1.0 / 2 = .5 ... size of blocks in texel units
	float texel_block = 1.0 / block_size;
	//.5 * current_block ... so if in block 1 coord is .5
	vec2 uv_offset = vec2(current_block * texel_block);

	uv_offset.x /= adsk_result_frameratio;

	uv_offset = (uv_offset + 1.0) * vec2(.5);

	vec3 front = texture2D(Front, uv_offset).rgb;

	gl_FragColor.rgb = front;
}
