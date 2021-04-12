#version 120

// Change the folling 4 lines to suite
#define INPUT adsk_results_pass1
#define Strength adsk_results_pass3
//#define VERTICAL
#define STRENGTH_CHANNEL
#define CENTER vec2(.5)
#define luma(col) dot(col, vec3(0.2126, 0.7152, 0.0722))

uniform sampler2D INPUT;

#define ratio adsk_result_frameratio
#define PI 3.141592653589793238462643383279502884197969

uniform float ratio;

#ifdef STRENGTH_CHANNEL
	uniform sampler2D Strength;
#endif

uniform int blur_type;
uniform vec2 direction;
uniform bool use_angle;
uniform float angle;
uniform bool strength_are_vectors;

#ifdef VERTICAL
	uniform float v_bias;
	float bias = v_bias;
	vec2 dir = vec2(0.0, 1.0);
#else
	uniform float h_bias;
	//:h_bias:1.0
	float bias = h_bias;
	vec2 dir = vec2(1.0, 0.0);
#endif



uniform bool matte_is_strength;
uniform bool bidirectional;
uniform bool blur_channels;

uniform float blur_amount;
uniform float blur_red;
uniform float blur_green;
uniform float blur_blue;
float blur_matte = 1.0;

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

vec4 gblur()
{
	 //The blur function is the work of Lewis Saunders.
	vec2 xy = gl_FragCoord.xy;
	if (xy.x > res.x) {
		//xy.x -= res.x;
	}

	if (blur_type == 1) {
		vec2 d = direction;
		bias = 1.0;

		if (use_angle) {
			float a = radians(angle);
			mat2 rm = mat2(
				cos(a), sin(a),
				sin(a), cos(a)
			);

			vec2 p = vec2(1.0, .5) - CENTER;

			p.x *= ratio;
			d = p * rm;
			d.x /= ratio;
			d += CENTER;
		}

		dir = d - CENTER;
	}

	float strength = 1.0;

	//Optional texture used to weight amount of blur
	#ifdef STRENGTH_CHANNEL
		if (matte_is_strength) {
			strength = texture2D(INPUT, gl_FragCoord.xy / res).a;
			/*
		} else if (strength_are_vectors) {
			strength = texture2D(Strength, gl_FragCoord.xy / res).r;
			*/
		} else {
			strength = abs(texture2D(Strength, gl_FragCoord.xy / res).r);
		}
	#endif

	//Blur code by Lewis Saunders

	float br = blur_red * blur_amount * bias * strength;
	float bg = blur_green * blur_amount * bias * strength;
	float bb = blur_blue * blur_amount * bias * strength;
	float bm = blur_matte * blur_amount * bias * strength;

	if (! blur_channels) {
		br = 1.0 * bias * strength * blur_amount;
		bg = 1.0 * bias * strength * blur_amount;
		bb = 1.0 * bias * strength * blur_amount;
		bm = 1.0 * bias * strength * blur_amount;
	}

	float support = max(max(max(br, bg), bb), bm) * 3.0;

	vec4 sigmas = vec4(br, bg, bb, bm);
	sigmas = max(sigmas, 0.0001);

	vec4 gx, gy, gz;
	gx = 1.0 / (sqrt(2.0 * PI) * sigmas);
	gy = exp(-0.5 / (sigmas * sigmas));
	gz = gy * gy;

	vec4 a = gx * texture2D(INPUT, xy * texel);
	vec4 energy = gx;
	gx *= gy;
	gy *= gz;

	for(float i = 1; i <= support; i++) {
    a += gx * texture2D(INPUT, (xy - i * dir) * texel);
		if (blur_type == 0 || bidirectional) {
    	a += gx * texture2D(INPUT, (xy + i * dir) * texel);
			energy += 2.0 * gx;
		} else if (blur_type == 1) {
			energy += gx;
		}

		gx *= gy;
		gy *= gz;
	}

	a /= energy;

	return a;
}

void main(void)
{
	gl_FragColor = gblur();
}
