#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;

//:scale:vec2(1.0)
//:invert:false
//:uscale:1.0
//:mirror_y:true
//:mirror_x:false
//:output_uv:false

uniform bool invert;
uniform float uscale;
uniform vec2 scale;
uniform bool mirror_x;
uniform bool mirror_y;
uniform bool output_uv;


#define center vec2(.5);

float tile(float coord) {
	//coord = st.x
	if (mod(floor(coord), 2) != 0) {
		coord = fract(coord);
	} else if (coord < 0.0 || coord > 1.0) {
		coord = fract(coord);
	}

	return coord;
}

float mirror(float coord) {
	if (mod(floor(coord), 2) != 0) {
		coord = 1.0 - fract(coord);
	} else {
		coord = fract(coord);
	}

	return coord;
}


void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	st -= center;
	vec2 s = scale * (vec2(uscale));
	if (invert) {
		st /= vec2(1.0) / s;
	} else {
		st /= s;
	}
	st += center;

	if (mirror_x) {
		st.x = mirror(st.x);
	} else {
		st.x = tile(st.x);
	}

	if (mirror_y) {
		st.y = mirror(st.y);
	} else {
		st.y = tile(st.y);
	}

	vec3 front = vec3(0.0);

	if (output_uv) {
		front.rg = st;
	} else {
		front = texture2D(Front, st).rgb;
	}

	gl_FragColor.rgb = front;
}
