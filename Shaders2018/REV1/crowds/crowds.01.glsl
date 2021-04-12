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
uniform float scale;
uniform float tiles;
uniform float gain;
uniform float off;
uniform float edge;

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

vec2 CosSin(float x) {
	vec2 si = fract(vec2(0.5,1.0) - x*2.0)*2.0 - 1.0;
	vec2 so = sign(0.5-fract(vec2(0.25,0.5) - x));
	return (20.0 / (si*si + 4.0) - 4.0) * so;
}

float rand(vec2 coords) {
	return fract(CosSin(dot(coords.xy, vec2(12.989 , 78.233))) * 43758.5453).r;
}

vec2 rotate_coords(vec2 coords, float r)
{
	float rot = radians(r);

	vec2 sin_cos = CosSin(rot);

	mat2 rm = mat2(
		sin_cos.g, sin_cos.r,
		-sin_cos.r,  sin_cos.g
	);

	return coords * rm;
}

vec4 sampleTex(vec2 coords, float t, float a) {
	float o = mod(t, 2.0) == 0 ? off : -off;
	coords -= vec2((t + 1) * o);
	coords = repeat_coords(coords, 1);

	vec3 dupe = texture2D(Front, coords).rgb;
	float matte = texture2D(Matte, coords).r;

	return vec4(dupe, clamp(a * matte, 0.0, 1.0));
}

vec2 dist(vec2 coords) {
	coords = abs(coords * vec2(2.0) - vec2(1.0));
	coords = abs(coords - vec2(1.0));

	return coords;
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;
	vec2 uv = st;
	vec2 noise = st;

	vec4 front = texture2D(Front, st);
	float alpha = 0.0;

	vec2 grid = st * vec2(tiles);
	vec2 this_block = floor(grid);
	vec2 tile_uvs = fract(grid);

	vec4 comp = front;
	float out_matte = 1.0;

	int iter = 3;
	vec4 dupes[] = vec4[](comp, comp, comp);

	for (int i = 0; i < iter; i++) {
		noise.x = rand(this_block + vec2(i));
		noise.y = rand(this_block.yx + vec2(i));

		st = gl_FragCoord.xy / res;

		st -= noise;
		st /= scale;
		st += noise;

		uv = fract(st * (tiles + i));
		uv = dist(uv);
		uv *= vec2(gain);

		alpha = uv.x * uv.y;
		alpha = clamp(alpha, 0.0, 1.0);

		dupes[i] = sampleTex(st, i, alpha);
		out_matte *= alpha;
	}

	comp = dupes[iter - 1];
	for (int i = iter - 2; i > -1; i--) {
		comp = mix(comp, dupes[i], dupes[i].a);
	}

	tile_uvs = dist(tile_uvs);
	tile_uvs *= vec2(gain);

	out_matte *= tile_uvs.x * tile_uvs.y;
	out_matte = clamp(out_matte, 0.0, 1.0);

	gl_FragColor = comp;
}
