#version 120

#define PI 3.14159
#define FrontLinear adsk_results_pass1
#define STRENGTH_CHANNEL

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

uniform sampler2D FrontLinear;

#ifdef STRENGTH_CHANNEL
	uniform sampler2D Strength;
#endif

uniform vec2 direction;
uniform bool bidirectional;
uniform bool use_angle;
uniform float angle;
uniform bool use_action_units;
uniform int repeat;

uniform bool blur_channels;
uniform float blur_amount;
uniform float blur_red;
uniform float blur_green;
uniform float blur_blue;
float blur_matte = 1.0;

vec2 center = vec2(.5);
vec2 dir = direction - center;

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

vec4 gblur()
{
	vec2 uv = gl_FragCoord.xy;

	float strength = 0.0;

	// Optional texture used to weight amount of blur
	#ifdef STRENGTH_CHANNEL
		strength = abs(texture2D(Strength, uv * texel).r);
	#endif

	if (use_action_units) {
		dir = texel * dir + .5;
	}

	if (use_angle) {
		float a = radians(angle);
		mat2 rm = mat2(
			cos(a), sin(a),
			sin(a), cos(a)
		);

		vec2 p = vec2(1.0, .5) - center;

		p.x *= adsk_result_frameratio;
		vec2 d = p * rm;
		d.x /= adsk_result_frameratio;
		d += center;

		dir = d - center;
	}

	//http://http.developer.nvidia.com/GPUGems3/gpugems3_ch40.html
	float sigma = blur_amount;
	sigma = max(sigma, 0.0001);

	float g0 = 1.0 / (sqrt(2.0 * PI) * sigma);
	float g1 = exp(-0.5 / (sigma * sigma));
	float g2 = g1 * g1;

	vec2 st = uv * texel;

	vec4 blurred = g0 * texture2D(FrontLinear, st);
	float pass = g0;
	g0 *= g1;
	g1 *= g2;

	for(float i = 1; i <= blur_amount * 3.0 * strength; i++) {
		st = (uv - i * dir) * texel;
		st = repeat_coords(st);

    blurred += g0 * texture2D(FrontLinear, st);
		pass += g0;

		if (bidirectional) {
			st = (uv + i * dir) * texel;
			st = repeat_coords(st);

  		blurred += g0 * texture2D(FrontLinear, st);
			pass += g0;
		}

		g0 *= g1;
		g1 *= g2;
	}

	blurred /= pass;

	return blurred;
}

void main(void)
{
	gl_FragColor = gblur();
}
