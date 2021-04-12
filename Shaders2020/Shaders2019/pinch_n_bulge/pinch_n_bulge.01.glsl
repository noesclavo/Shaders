#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform float scale;
uniform float radius;
uniform float edge_hardness;
uniform vec2 center;
uniform int repeat;

vec2 repeat_coords(vec2 coords) {
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
	vec2 coords = st;

	vec2 center_ = center;

	vec2 xx = sin(coords * PI);

	coords.x *= ratio;
	center_.x *= ratio;
	float c = distance(center_, coords) * 2;
	center_.x /= ratio;
	coords.x /= ratio;

	c /= radius;

	c = 1.0 - c;

	float s = mix(1.0, scale / 100, c);

	coords -= center;
	coords /= s;
	coords += center;

	//mirror edges
	/*
	vec2 scoords = sin(coords * PI);
	xx = vec2(1.0) - step(vec2(0.0), scoords);
	coords = abs(xx - fract(coords));
	*/

	coords = repeat_coords(coords);

	vec3 pinched = texture2D(Front, coords).rgb;
	vec3 front = texture2D(Front, st).rgb;

	c *= edge_hardness;
	c = clamp(c, 0.0, 1.0);

	vec3 comp = mix(front, pinched, c);

	c = xx.x;

	gl_FragColor = vec4(comp, c);
}
