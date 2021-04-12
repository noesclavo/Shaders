#version 120

#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform int repeat;

#define PI 3.1415926535897932
vec2 repeat_coords(vec2 coords, int repeat) {

  if (repeat == 1) {
    coords = fract(coords);
  } else if (repeat == 2) {
	  vec2 xx = vec2(1.0) - step(vec2(0.0), sin(coords * PI));
	  coords = abs(xx - fract(coords));
  } else if (repeat == 3) {
		if (any(notEqual(clamp(coords, 0.0, 1.0), coords))) {
			discard;
		}
	}

	return coords;
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	st -= vec2(.5);
	st /= .25;
	st += vec2(.5);

	st = repeat_coords(st, repeat);

	vec3 front = texture2D(Front, st).rgb;

	gl_FragColor.rgb = front;
}
