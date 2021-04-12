#version 120

#define PI 3.14159
#define Blurred adsk_results_pass4
#define VERTICAL
//#define STRENGTH_CHANNEL

uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

uniform sampler2D Blurred;
uniform sampler2D adsk_results_pass1;
uniform sampler2D adsk_results_pass3;

#ifdef STRENGTH_CHANNEL
	uniform sampler2D Strength;
#endif

uniform float blur_amount;

#ifdef VERTICAL
	float bias = adsk_result_pixelratio;
	vec2 dir = vec2(0.0, 1.0);
#else
	float bias = 1.0;
	vec2 dir = vec2(1.0, 0.0);
#endif

uniform float gamma;
uniform float gain;

float get_edge()
{
	vec2 uv = gl_FragCoord.xy;
	vec2 st = uv * texel;
	float blur = texture2D(adsk_results_pass3, st).a;
	float matte = texture2D(adsk_results_pass1, st).a;

	float edge = 1.0 - abs(blur - (1.0 - blur));
	edge = smoothstep(.09, 1.0, edge);
	edge = pow(edge, 1.0 / gamma);
	edge *= gain;
	edge = clamp(edge, 0.0, 1.0);

	if (edge > 0.0) {
		//edge += matte;
	}


	return edge;
}

vec4 gblur()
{
	vec2 uv = gl_FragCoord.xy;

	float strength = 1.0;

	// Optional texture used to weight amount of blur
	#ifdef STRENGTH_CHANNEL
		strength = abs(texture2D(Strength, uv * texel).r);
	#endif

	strength = get_edge();

	//http://http.developer.nvidia.com/GPUGems3/gpugems3_ch40.html
	float sigma = blur_amount * bias * strength;
	sigma = max(sigma, 0.0001);

	float g0 = 1.0 / (sqrt(2.0 * PI) * sigma);
	float g1 = exp(-0.5 / (sigma * sigma));
	float g2 = g1 * g1;

	vec2 st = uv * texel;

	vec4 blurred = g0 * texture2D(Blurred, st);
	float pass = g0;
	g0 *= g1;
	g1 *= g2;

	for(float i = 1; i <= blur_amount * 3; i++) {
		st = (uv - i * dir) * texel;

    blurred += g0 * texture2D(Blurred, st);
		pass += g0;

		st = (uv + i * dir) * texel;

  	blurred += g0 * texture2D(Blurred, st);
		pass += g0;

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
