#version 120

#define PI 3.#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;

uniform int peices;
uniform int op;
uniform int pos_x, pos_y;
uniform int vpos_x, vpos_y;
uniform int scale_x, scale_y;
uniform float strength;
uniform int align;

void main(void) {
	vec2 st = gl_FragCoord.xy / res;
	vec2 uv = st;
	float trash = 0.0;

	vec2 pos = op == 0 ? vec2(pos_x, pos_y) * texel : vec2(vpos_x, vpos_y) * texel * vec2(.01);
	vec2 scale = vec2(scale_x, scale_y) / vec2(100);

	vec2 block_bounds = uv * peices;
	vec2 current_block = floor(block_bounds);
	vec2 next_block = current_block + vec2(1.0);
	vec2 block_size = vec2(1.0 / peices);
	vec2 center = vec2(.5);

	vec4 uv_bounds = vec4(
		current_block * block_size,
		next_block * block_size
	);

	//when a vertical blinds option is true, multiply pos by peices
	//I don't know why
	float mult = op != 0 ? peices : 1.0;
	//make pos a percentage of the block
	vec2 uv_offset = (pos * vec2(mult) / vec2(100)) * res * block_size ;

	//strength
	//create a block grad
	vec2 bg = current_block / vec2(peices - 1);
	//or not
	bg = st;
	vec2 j = bg;

	//direction of strength
	//j = strength > 0.0 ? j += vec2(1.0) : j -= vec2(1.0);
	j = strength > 0.0 ? j += vec2(1.0) : j - vec2(1.0);
	j = strength < 0.0 ? vec2(1.0) - j : j;

	vec2 influence = mix(j, vec2(1.0), 1.0 - abs(strength));

	uv_offset = mix(vec2(0.0), uv_offset, influence);

	if (op == 0) {
		uv -= uv_offset;
	} else if (op == 1) {
		//translate vertical
		if (mod(current_block.x, 2.0) == 0) {
			uv.y +=  uv_offset.y;
		} else {
			uv -= uv_offset;
		}

		uv.x = st.x;

		// y bounds lo and hi
		uv_bounds.yw = vec2(0.0, 1.0);
	} else if (op == 2) {
		//translate horizontal
		if (mod(current_block.y, 2.0) == 0) {
			uv.x +=  uv_offset.x;
		} else {
			uv -= uv_offset;
		}

		uv.y = st.y;

		// x bounds lo and hi
		uv_bounds.xz = vec2(0.0, 1.0);
	} else if (op == 3) {
		//scale
		vec2 uv_scale = scale;

		if (align == 0) {
			//center left
			center = (current_block / vec2(peices));
		} else if (align == 1) {
			//center right
			center = (next_block / vec2(peices));
		} else if (align == 2) {
			//center middle
			center = (current_block / vec2(peices)) + block_size * vec2(.5);
		}

		uv -= center;
		uv /= scale;
		uv += center;
	}

	if (uv.x < uv_bounds.x || uv.x > uv_bounds.z) {
		discard;
	}

	if (uv.y < uv_bounds.y || uv.y > uv_bounds.w) {
		discard;
	}

	vec4 front = texture2D(Front, uv);

	gl_FragColor = front;
}
