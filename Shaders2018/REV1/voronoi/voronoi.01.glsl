#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

vec3 adsk_hsv2rgb(vec3 col);
float adsk_getLuminance( in vec3 color );

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform int cells;
uniform float seed;
uniform float blend;
uniform int passes;
uniform bool manhattan;
uniform bool show_middle;
uniform bool use_texture;
uniform bool output_uvs;
uniform float saturation;
uniform float value;
uniform int distance_metric;

vec2 CosSin(float x) {
	vec2 si = fract(vec2(0.5,1.0) - x*2.0)*2.0 - 1.0;
	vec2 so = sign(0.5-fract(vec2(0.25,0.5) - x));
	return (20.0 / (si*si + 4.0) - 4.0) * so;
}

float rand(vec2 coords, float seed) {
	return fract(CosSin(dot(coords.xy, vec2(12.989 + seed, 78.233))) * 43758.5453).r;
}

vec4 voronoi(vec2 coords, float seed) {
	float d = 8.0;
	vec4 outcol = vec4(0.0);

	for (int i = 0; i < cells; i++) {
		float x = rand(vec2(i), i * seed);
		float y = rand(vec2(i-1), (i-1) * seed);

		vec2 p = vec2(x, y);

		coords.x *= adsk_result_frameratio;
		p.x *= adsk_result_frameratio;

		float tmp = distance(coords, p);

		if (distance_metric == 1) {
			tmp = length(p.x - coords.x) + length(p.y - coords.y);
		} else if (distance_metric == 2) {
			tmp = max(length(p.x - coords.x),  length(p.y - coords.y));
		}

		if (tmp < d) {
			float hue = rand(p, .666);
			float sat = max(rand(p, .12341), .25) * saturation;
			float val = max(rand(p, .66239), .25) * value;

			vec3 rgb = adsk_hsv2rgb(vec3(hue, sat, val));
			rgb = clamp(rgb, 0.0, 1.0);

			outcol.a = smoothstep(.995, 1.0, 1.0 - distance(p, coords));

			if (use_texture) {
				p.x /= adsk_result_frameratio;
				outcol.rgb = texture2D(Front, p).rgb;

				float desat = adsk_getLuminance(outcol.rgb);
				outcol.rgb = mix(vec3(desat), outcol.rgb, saturation);
				outcol.rgb *= value;
			} else if (output_uvs) {
				outcol.rgb = vec3(p, 0.0);
			} else {
				outcol.rgb = rgb;
			}

			d = tmp;
		}

		coords.x /= adsk_result_frameratio;
	}

	if (show_middle) {
		outcol.rgb *= vec3(1.0 - outcol.a);
	}

	return outcol;
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;
	vec4 outcol = vec4(0.0);

	for (int i = 0; i < passes; i++) {
		outcol = mix(outcol, voronoi(st, seed + i), .5);
	}

	gl_FragColor = outcol;
}
