#version 120

#define PI 3.1415926535897932
#define fratio adsk_result_frameratio
#define pratio adsk_result_pixelratio

vec3 adsk_hsv2rgb(in vec3 src);
float adsk_getLuminance(in vec3 src);

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform float gain;

#define top .5
#define bottom .175

vec4 sobel(vec2 st, sampler2D Input)
{
  vec4 col = vec4(0.0);
  float sx = 0.0;
  float sy = 0.0;

  mat3 gx = mat3(
    bottom, 0.0, -bottom,
    top, 0.0, -top,
    bottom, 0.0, -bottom
  );

  mat3 gy = mat3(
    bottom, top, bottom,
    0.0, 0.0, 0.0,
    -bottom, -top, -bottom
  );

  for(int i = -1; i <= 1; i++) {
    for(int j = -1; j <= 1; j++) {
      vec3 col_in = texture2D(Input, st + vec2(i, j) * texel).rgb;
      float mono = adsk_getLuminance(col_in);
      sx += mono * float(gx[1 + i][1 + j]);
      sy += mono * float(gy[1 + i][1 + j]);
    }
  }

  float g = abs(sx) + abs(sy);

  // make a normal map if you want
  float sz = .5 * sqrt(1.0 - sx * sx - sy * sy);
  vec3 norm = normalize(vec3(2.0 * sy, 2.0 * sx, sz) );

  float r = atan(sy/sx);
  vec3 hsv = vec3(r, 1.0, 1.0);
  vec3 rgb = adsk_hsv2rgb(hsv);

  col.rgb = rgb * g;
  //col = vec4(g * gain);
  col.rgb = norm;

  return col;
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;
  vec4 edges = sobel(st, Front);

	gl_FragColor = edges;
}
