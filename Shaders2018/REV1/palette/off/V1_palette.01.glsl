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

vec2 rotate(vec2 coords, float r)
{
	float rot = radians(r);

	mat2 rm = mat2(
		cos(rot), sin(rot),
		-sin(rot), cos(rot)
	);

	coords *= rm;

	return coords;
}



void main(void) {
	vec2 st = gl_FragCoord.xy / res;


  vec3 color_1_hsv = dominant;
	float color_1_gain = color_1_hsv.z;
	float color_1_sat = color_1_hsv.y;

  d_hue = radians(color_1_hsv.x);

  if (dominant_from_front) {
    vec3 front = texture2DLod(Front, st, 10).rgb;

    color_1_hsv = adsk_rgb2hsv(front) * vec3(360, 100, 100);
    color_1_gain = (color_1_gain + color_1_hsv.z) * .5;
    color_1_sat = (color_1_sat + color_1_hsv.y) * .5;
  }

	vec3 color_1 = getRGB( d_hue, color_1_sat * 0.01 ) * vec3( color_1_gain * 0.01);
	vec3 sat_1 = getRGB( d_hue / 360.0, 1 ) * vec3( color_1_gain * .01);

  if (dominant_from_front) {
	   color_1 = getRGB( color_1_hsv.x / 360.0, front_sat * 0.01 ) * vec3( front_gain * 0.01);
     color_1_sat = front_sat;
  }

	float t = separation;
  if (type > 0) {
	 t = type == 1 ? 0 : t;
	 t = type == 2 ? 120 * 2.0 : t * 3;
  }

	vec3 color_2 = getRGB( radians(color_1_hsv.x + t), ((color_2_sat + color_1_sat) * .5) * 0.01 ) * vec3( color_2_gain * 0.01);
	vec3 sat_2 = getRGB( radians(color_1_hsv.x + t), 1 ) * vec3( color_2 * .01);

  t *= 2;
  if (type > 0) {
	   t = type == 1 ? 0 : t;
	   t = type == 2 ? 120 * 2.0 : t * 2;
	   t = type == 3 ? 180 : t;
   }

	vec3 color_3 = getRGB( radians(color_1_hsv.x + t), ((color_3_sat + color_1_sat) * .5) * 0.01 ) * vec3( color_3_gain * 0.01);
	vec3 sat_3 = getRGB( radians(color_1_hsv.x + t), 1 ) * vec3( color_3 * .01);

  t *= 3;
  if (type > 0) {
	   t = type == 1 ? 0 : t;
	   t = type == 2 ? 0 : t;
	   t = type == 3 ? 0 : t;
   }

	vec3 color_4 = getRGB( radians(color_1_hsv.x + t), ((color_4_sat + color_1_sat) * .5) * 0.01 ) * vec3( color_4_gain * 0.01);
	vec3 sat_4 = getRGB( radians(color_1_hsv.x + t), 1 ) * vec3( color_4 * .01);

  t *= 4;
  if (type > 0) {
	   t = type == 1 ? 0 : t;
	   t = type == 2 ? 120 : t * 4;
	   t = type == 3 ? 180 : t;
  }

	vec3 color_5 = getRGB( radians(color_1.x + t), ((color_5_sat + color_1_sat) * .5) * 0.01 ) * vec3( color_5_gain * 0.01);
	vec3 sat_5 = getRGB( radians(color_1.x + t), 1 ) * vec3( color_5 * .01);

	vec3 outcol = vec3(0.0);

	float alpha_1 = 1.0 - step(.2, st.x);
	float alpha_2 = 1.0 - step(.4, st.x);
	float alpha_3 = 1.0 - step(.6, st.x);
	float alpha_4 = 1.0 - step(.8, st.x);
	float alpha_5 = 1.0;

	float cut = 1.0 - fract(st.x * 5.0);
	float sat_alpha = 1.0 - step(25 * texel.y, st.y);

	outcol = color_5;
	outcol = mix(outcol, color_4, alpha_4);
	outcol = mix(outcol, color_3, alpha_3);
	outcol = mix(outcol, color_2, alpha_2);
	outcol = mix(outcol, color_1, alpha_1);

	float m = 0.0;

	for (float i = .1; i <= 1; i += .1) {
		m += mix(m, .1, 1.0 - step(i, 1.0 - st.y));
	}

	outcol = mix(outcol, outcol * (m + .1), (1.0 - sat_alpha) * shade_mix);

	m = 0.0;
	for (float i = .5; i <= 1; i += .5) {
		m += mix(m, .1, 1.0 - step(i, 1.0 - fract(st.x * 5)));
	}

	outcol = mix(outcol, outcol *(m + .1), .5 * shade_mix * (1.0 - sat_alpha));


	vec3 satcol = sat_5;
	satcol = mix(outcol, sat_4, alpha_4);
	satcol = mix(outcol, sat_3, alpha_3);
	satcol = mix(outcol, sat_2, alpha_2);
	satcol = mix(outcol, sat_1, alpha_1);

	satcol = mix(satcol, vec3(1.0), cut);

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

	satcol *= lines;

	outcol = mix(outcol, satcol, sat_alpha);

	gl_FragColor = vec4(outcol, m);
}
