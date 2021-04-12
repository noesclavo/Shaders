#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

#define TEX adsk_results_pass1
uniform sampler2D adsk_results_pass1;
uniform sampler2D selective_tex;

uniform float blur_r, blur_g, blur_b;
uniform float bias;
uniform float blur;

vec2 repeat_coords(vec2 coords) {
	if (mod(floor(coords.x), 2) != 0) {
		coords.x = 1.0 - fract(coords.x);
	} else {
		coords.x = fract(coords.x);
	}
	if (mod(floor(coords.y), 2) != 0.0) {
		coords.y = 1.0 - fract(coords.y);
	} else {
		coords.y = fract(coords.y);
	}

	return coords;
}

vec4 gblur() {
  vec2 dir = vec2(1.0, 0.0);

  vec2 uv = gl_FragCoord.xy;
  vec2 st = uv * texel;

  float strength = texture2D(selective_tex, st).r;

  float br = blur_r * strength * bias * blur;
  float bg = blur_g * strength * bias * blur;
  float bb = blur_b * strength * bias * blur;
  float bm = blur;

  //http://http.developer.nvidia.com/GPUGems3/gpugems3_ch40.html
  vec4 sigma = vec4(br, bg, bb, bm);
  sigma = max(sigma, 0.000001);

  vec4 g0 = 1.0 / (sqrt(2.0 * PI) * sigma);
  vec4 g1 = exp(-0.5 / (sigma * sigma));
  vec4 g2 = g1 * g1;


  vec4 blurred = g0 * texture2D(TEX, st);
  vec4 norm = g0;
  g0 *= g1;
  g1 *= g2;

  for(float i = 1; i <= blur * bias * strength * 3.0; i++) {
    st = (uv - i * dir) * texel;
    st = repeat_coords(st);

    blurred += g0 * texture2D(TEX, st);

    st = (uv + i * dir) * texel;
    st = repeat_coords(st);

    blurred += g0 * texture2D(TEX, st);

    norm += g0 * 2.0;

    g0 *= g1;
    g1 *= g2;
  }

  blurred /= norm;

  return blurred;
}

void main(void) {
  gl_FragColor = gblur();
}
