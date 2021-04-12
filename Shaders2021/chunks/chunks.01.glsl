#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform sampler2D Matte;
uniform sampler2D Strength;
uniform int type;

uniform float square_size;
uniform float size_x;
uniform float size_y;
uniform float uniform_spread_size;
uniform float spread_x;
uniform float spread_y;

uniform vec2 center;
uniform float blend;
uniform int repeat;
uniform bool static_noise;
uniform float mix_over_front;
uniform bool random;
uniform bool output_uv;
uniform float speed;

vec2 CosSin(float x) {
	vec2 si = fract(vec2(0.5,1.0) - x*2.0)*2.0 - 1.0;
	vec2 so = sign(0.5-fract(vec2(0.25,0.5) - x));
	return (20.0 / (si*si + 4.0) - 4.0) * so;
}

float rand(vec2 coords, float seed, float s) {
	return fract(CosSin(dot(coords.xy, vec2(12.989 + s * seed, 78.233))) * 43758.5453).r;
}

#define PI 3.1415926535897932
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

	vec3 orig = texture2D(Front, st).rgb;
	float strength = texture2D(Strength, st).r;

    vec2 size = vec2(square_size * strength);
	vec2 rect_size = vec2(size_x, size_y) * strength;

	float t = floor(adsk_time * speed);

	float rmult = 0.0;
	if (random) {
		rmult = rand(floor(st * vec2(10.)), .61328, t) * square_size;
	}

	vec2 s = type == 0 ? vec2(size + rmult) * texel : (rect_size + vec2(rmult)) * texel;

	st -= vec2(.5);

	float u = rand(1.0 + floor(st / s), .23488, t);
	float v = rand(ceil(st / s), .9883, t);
	//make it as random as possible
	u = rand(1.0 + ceil(st / s), .23488, t);
	v = rand(floor(st / s), .9883, t);

	st += vec2(.5);

	vec2 uv = fract(st + vec2(u, v));

	vec2 spread = vec2(spread_x, spread_y) * vec2(uniform_spread_size) * .01 * vec2(strength);

	st = mix(st, uv, spread);
	st = repeat_coords(st);

	vec3 front = texture2D(Front, st).rgb;
	float matte = texture2D(Matte, st).r;
	vec3 col2 = texture2D(Front,  st + 10 * texel).rgb;

	//psycho
	vec3 diff = abs(front.rgb - col2);
	diff = step(.1, diff);
	front.rgb = mix(front.rgb, diff, blend);

	//mix over original image
	front.rgb = mix(orig.rgb, front.rgb, mix_over_front);

	if (output_uv) {
		front.rgb = vec3(st, 0.0);
	}

	gl_FragColor = vec4(front, matte);
}
