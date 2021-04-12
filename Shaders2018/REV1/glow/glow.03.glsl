#version 120
//threshold pass, create threshold, grade and tint front, multiply front by threshold

#define FrontPremult adsk_results_pass1

vec3  adsk_hsv2rgb( vec3 hsv );
float adsk_getLuminance( in vec3 color );
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D FrontPremult;
uniform float threshold;
uniform float falloff;
uniform vec3 tint;
float saturation = 1.0;
uniform float brightness;
uniform bool invert_threshold;
float gamma = 1.0;

vec3 getRGB( float hue, float sat)
{
    vec3 rgb =  adsk_hsv2rgb( vec3( hue, sat, 1.0 ) );

    rgb = clamp(rgb, 0.0, 1.0);

    return rgb;
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec3 front_premult = texture2D(FrontPremult, st).rgb;
	float luma = adsk_getLuminance(front_premult);
	//float thresh = smoothstep(threshold - falloff, threshold, luma);

  float c = clamp(luma, 0.0, threshold);
	float c_gain = 1 / threshold * c;
	float c_contrast = (c_gain - 1.0) * (1.0 / falloff) + 1.0;
  float thresh = clamp(c_contrast, 0.0, 1.0);

  thresh = invert_threshold ? 1.0 - thresh : thresh;

	//Saturation
	front_premult = mix(vec3(luma), front_premult, saturation);

	//Gamma
	front_premult = pow(front_premult, vec3(1.0 - (gamma - 1.0)));

	//Tint Hue, Gain and Tint Saturation
	vec3 g_offset = getRGB( tint.x / 360.0, tint.y * .01 ) * vec3( tint.z * 0.05);
	front_premult *= g_offset;

	front_premult *= thresh;

	gl_FragColor = vec4(front_premult, thresh);
}
