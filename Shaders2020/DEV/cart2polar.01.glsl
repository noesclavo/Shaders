#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform bool flip;
uniform bool center;
uniform int num;
uniform float angle;
uniform float thickness;
uniform float loops;

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
	vec2 uv = st;
	vec4 outcol;

	uv = uv * vec2(2.0) - vec2(1.0);
	uv.x *= adsk_result_frameratio;
	//uv *= 10;

	//convert to polar
	float r = sqrt(uv.x * uv.x + uv.y * uv.y);
	float theta = atan(uv.y, uv.x);
	float phi = acos(-1 / r);

  if (theta < 0) {
    //theta *= 2 * PI;
  }

	vec2 polar = vec2(r, theta);

	polar = repeat_coords(polar, 2);

	//convert back to cartesian
	//uv.x = r * cos(theta);
	//uv.y = r * sin(theta);

	//circle: r < radius;
	//flower: thickness * cos(loops * theta)
	//equiangluar spiral: hickness * exp(theta * 1/tan(loops))

	outcol = texture2D(Front, polar);


	gl_FragColor = outcol;
}
