#version 120

//blur comp horizontally

#define PI 3.14159
#define center vec2(.5)
#define FrontLinear adsk_results_pass1
#define Strength adsk_results_pass4
//#define VERTICAL
#define STRENGTH_CHANNEL

uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

uniform sampler2D FrontLinear;

#ifdef STRENGTH_CHANNEL
	uniform sampler2D Strength;
#endif

uniform float comp_blur_amount;

#ifdef VERTICAL
	float v_bias = 1.0;
	float bias = v_bias * adsk_result_pixelratio;
	vec2 dir = vec2(0.0, 1.0);
#else
	float h_bias = 1.0;
	float bias = h_bias;
	vec2 dir = vec2(1.0, 0.0);
#endif

vec4 gblur()
{
	vec2 uv = gl_FragCoord.xy;

	float strength = 1.0;

	// Optional texture used to weight amount of blur
	#ifdef STRENGTH_CHANNEL
		strength = abs(texture2D(Strength, uv * texel).a);
	#endif

	//http://http.developer.nvidia.com/GPUGems3/gpugems3_ch40.html
	float sigma = comp_blur_amount * bias * strength;
	sigma = max(sigma, 0.0001);

	float g0 = 1.0 / (sqrt(2.0 * PI) * sigma);
	float g1 = exp(-0.5 / (sigma * sigma));
	float g2 = g1 * g1;

	vec2 st = uv * texel;

	vec4 blurred = g0 * texture2D(FrontLinear, st);
	float pass = g0;
	g0 *= g1;
	g1 *= g2;

	for(float i = 1; i <= comp_blur_amount * 3.0; i++) {
		st = (uv - i * dir) * texel;

    blurred += g0 * texture2D(FrontLinear, st);
		pass += g0;

		st = (uv + i * dir) * texel;

  	blurred += g0 * texture2D(FrontLinear, st);
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
