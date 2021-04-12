#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

vec3  adsk_hsv2rgb( vec3 hsv );

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;

uniform float grid_size;
uniform float grid_size_x;
uniform float grid_size_y;
uniform float line_weight;
uniform float line_weight_x;
uniform float line_weight_y;
uniform float translate_x;
uniform float translate_y;
uniform vec3 grid_color;
uniform bool center_grid;

vec3 getRGB( float hue, float sat) {
    vec3 rgb =  adsk_hsv2rgb( vec3( hue, sat, 1.0 ) );

    rgb = clamp(rgb, 0.0, 1.0);

    return rgb;
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;
  float pr = adsk_result_pixelratio;

	vec2 abs_grid_size = vec2(grid_size) * vec2(grid_size_x * ratio, grid_size_y);

	st -= vec2(.5);
	st *= abs_grid_size;

	if (! center_grid) {
		st += vec2(.5);
	}

	st -= vec2(translate_x, translate_y);

	abs_grid_size *= vec2(.5);

	vec2 grid = step(vec2(1.0) - vec2(line_weight * .5) * vec2(line_weight_x, line_weight_y * pr) * abs_grid_size  * texel, fract(st));
	grid += step(vec2(1.0) - vec2(line_weight * .5) * vec2(line_weight_x, line_weight_y * pr) * abs_grid_size * texel, 1.0 - fract(st));

	vec4 outcol = vec4(0.0);

	vec3 g_offset = getRGB( grid_color.x / 360.0, grid_color.y * .01 ) * vec3( grid_color.z * .01);

	outcol.rgb = mix(outcol.rgb, g_offset, clamp(grid.x + grid.y, 0.0, 1.0));
	outcol.a = clamp(grid.x + grid.y, 0.0, 1.0);

  outcol.a = adsk_result_pixelratio;

	gl_FragColor = outcol;
}
