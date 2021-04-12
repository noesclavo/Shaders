#version 120
#extension GL_ARB_shader_texture_lod : enable

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

float adsk_getLuminance( in vec3 color );

uniform sampler2D Front;

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform vec3 dominant;
uniform float x;
uniform float shade_mix;
uniform int separation;
uniform int type;
uniform bool dominant_from_front;
uniform float color_edge;

uniform float front_gain;
uniform float front_sat;

uniform float color_1_gain;
uniform float color_2_gain;
uniform float color_3_gain;
uniform float color_4_gain;
uniform float color_5_gain;

uniform float color_2_sat;
uniform float color_3_sat;
uniform float color_4_sat;
uniform float color_5_sat;

vec3 adsk_hsv2rgb( in vec3 hsv );
vec3 adsk_rgb2hsv( in vec3 rgb );

vec3 getRGB( float hue, float sat)
{
    vec3 rgb =  adsk_hsv2rgb( vec3( hue, sat, 1.0 ) );

    rgb = clamp(rgb, 0.0, 1.0);

    return rgb;
}

float norm(float x) {
  return x / 360.0;
}

float avg(float x, float y) {
  return (x + y) * .5;
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec3 outcol = vec3(0.0);

  //Establish the dominant color
  vec3 color_1_hsv = dominant;
	float color_1_gain = color_1_hsv.z;
	float color_1_sat = color_1_hsv.y;

  float d_hue = norm(color_1_hsv.x);

  if (dominant_from_front) {
    vec3 front = texture2DLod(Front, st, 10).rgb;

    color_1_gain = avg(color_1_gain, color_1_hsv.z);
    color_1_sat = avg(color_1_sat, color_1_hsv.y);

    d_hue = adsk_rgb2hsv(front).r;
  }

	vec3 color_1 = getRGB( d_hue, color_1_sat * 0.01 ) * vec3( color_1_gain * 0.01);
	vec3 sat_1 = getRGB( d_hue, 1 ) * vec3( color_1_gain * .01);

  if (dominant_from_front) {
	   color_1 = getRGB( d_hue, front_sat * 0.01 ) * vec3( front_gain * 0.01);
     color_1_sat = front_sat;
  }

  //Establish colors 2 - 5 based upon the dominant color and the color rule and
  //alternate the order of increments so we can see different hues next to each other
  float monochrome = 0.0;
  float triad = 120.0;
  float complementary = 180.0;

  //Analagous - default rule
  float rotate = norm(separation);
  //Other rules, monochrome, triad mixing and complementary
  rotate = type == 1 ? monochrome : rotate;
  rotate = type == 2 ? norm(triad * 1.0) : rotate;
  rotate = type == 3 ? norm(complementary) : rotate;

	vec3 color_2 = getRGB(  d_hue + rotate, avg(color_2_sat, color_1_sat) * 0.01 ) * vec3( color_2_gain * 0.01);
  vec3 sat_2 = adsk_hsv2rgb(vec3(d_hue + rotate, 1, 1));

  rotate = type == 0 ? norm(separation * 2.0) : rotate;
  rotate = type == 2 ? norm(triad * 2.0) : rotate;
  rotate = type == 3 ? norm(complementary * 2.0) : rotate;

	vec3 color_3 = getRGB( d_hue + rotate, avg(color_3_sat, color_1_sat) * 0.01 ) * vec3( color_3_gain * 0.01);
  vec3 sat_3 = adsk_hsv2rgb(vec3(d_hue + rotate, 1, 1));

  rotate = type == 0 ? norm(separation * 3.0) : rotate;
  rotate = type == 2 ? norm(triad * 3.0) : rotate;
  rotate = type == 3 ? norm(complementary) : rotate;

	vec3 color_4 = getRGB( d_hue + rotate, avg(color_4_sat, color_1_sat) * 0.01 ) * vec3( color_4_gain * 0.01);
  vec3 sat_4 = adsk_hsv2rgb(vec3(d_hue + rotate, 1, 1));

  rotate = type == 0 ? norm(separation * 4.0) : rotate;
  rotate = type == 2 ? norm(triad * 1.0) : rotate;
  rotate = type == 3 ? norm(complementary * 2.0) : rotate;

	vec3 color_5 = getRGB( d_hue + rotate, avg(color_5_sat, color_1_sat) * 0.01 ) * vec3( color_5_gain * 0.01);
  vec3 sat_5 = adsk_hsv2rgb(vec3(d_hue + rotate, 1, 1));

  //Create alphas
	float sat_alpha = 1.0 - step(.1, st.y);
	float alpha_1 = 1.0 - step(.2, st.x);
	float alpha_2 = 1.0 - step(.4, st.x);
	float alpha_3 = 1.0 - step(.6, st.x);
	float alpha_4 = 1.0 - step(.8, st.x);
	float alpha_5 = 1.0;

  //Blurry alphas
  float blur = color_edge * texel.x;
	float alpha_1_blur = 1.0 - smoothstep(.2 - blur, .2 + blur, st.x);
	float alpha_2_blur = 1.0 - smoothstep(.4 - blur, .4 + blur, st.x);
	float alpha_3_blur = 1.0 - smoothstep(.6 - blur, .6 + blur, st.x);
	float alpha_4_blur = 1.0 - smoothstep(.8 - blur, .8 + blur, st.x);
	float alpha_5_blur = 1.0;

  //Mix the blurry alphas over the alphas only when not in saturation bar
  alpha_1 = mix(alpha_1_blur, alpha_1, sat_alpha);
  alpha_2 = mix(alpha_2_blur, alpha_2, sat_alpha);
  alpha_3 = mix(alpha_3_blur, alpha_3, sat_alpha);
  alpha_4 = mix(alpha_4_blur, alpha_4, sat_alpha);
  alpha_5 = mix(alpha_5_blur, alpha_5, sat_alpha);

  //Mix Colors
	outcol = color_5;
	outcol = mix(outcol, color_4, alpha_4);
	outcol = mix(outcol, color_3, alpha_3);
	outcol = mix(outcol, color_2, alpha_2);
	outcol = mix(outcol, color_1, alpha_1);

  //Shades
	float m = 0.0;

	for (float i = .1; i <= 1; i += .1) {
		m += mix(m, .1, 1.0 - step(i, 1.0 - st.y));
	}

	outcol = mix(outcol, outcol * (m + .1), (1.0 - sat_alpha) * shade_mix);

	m = 0.0;
	for (float i = .5; i <= 1; i += .5) {
		m += mix(m, .1, 1.0 - step(i, 1.0 - fract(st.x * 5)));
	}

	outcol = mix(outcol, outcol * (m + .1), .5 * shade_mix * (1.0 - sat_alpha));

  //Saturation bars
	float cut = 1.0 - fract(st.x * 5.0);

	outcol = mix(outcol, sat_5, alpha_5 * sat_alpha);
	outcol = mix(outcol, sat_4, alpha_4 * sat_alpha);
	outcol = mix(outcol, sat_3, alpha_3 * sat_alpha);
	outcol = mix(outcol, sat_2, alpha_2 * sat_alpha);
	outcol = mix(outcol, sat_1, alpha_1 * sat_alpha);

	outcol = mix(outcol, vec3(1.0), sat_alpha * cut);

  //Saturation lines
	vec3 lines = vec3(1.0);

	float line = clamp(distance(1.0 - cut, ((color_5_sat + color_1_sat) * .5) * .01) * res.x * .175, 0.0, 1.0);
	lines = mix(lines, vec3(line), alpha_5);

	line = clamp(distance(1.0 - cut, ((color_4_sat + color_1_sat) * .5) * .01) * res.x * .175, 0.0, 1.0);
	lines = mix(lines, vec3(line), alpha_4);

	line = clamp(distance(1.0 - cut, ((color_3_sat + color_1_sat) * .5) * .01) * res.x * .175, 0.0, 1.0);
	lines = mix(lines, vec3(line), alpha_3);

	line = clamp(distance(1.0 - cut, ((color_2_sat + color_1_sat) * .5) * .01) * res.x * .175, 0.0, 1.0);
	lines = mix(lines, vec3(line), alpha_2);

	line = clamp(distance(1.0 - cut, color_1_sat * .01) * res.x * .175, 0.0, 1.0);
	lines = mix(lines, vec3(line), alpha_1);

	outcol = mix(outcol, outcol * lines, sat_alpha);

	gl_FragColor = vec4(outcol, m);
}
