#version 120
//Strength pass

#define ratio adsk_result_frameratio

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Strength;
uniform float blur_amount;
uniform bool lat;

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

	if (lat) {
    st -= vec2(.5);
    st *= 1.0 + blur_amount * 5 * texel;
    st += vec2(.5);
  }

	vec2 mirror = repeat_coords(st, 2);
  vec2 tile = repeat_coords(st, 1);

  st = vec2(tile.x, mirror.y);

	float strength = texture2D(Strength, st).r;

	gl_FragColor = vec4(strength);
}
