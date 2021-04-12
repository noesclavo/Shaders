#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

vec3 adsk_hsv2rgb( in vec3 src );

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;
uniform float bump;

uniform sampler2D Front;
uniform float mult;

uniform float lo;
uniform float hi;

void main(void) {
	vec2 st = gl_FragCoord.xy / res;


mat3 sx = mat3(
    lo, hi, lo,
    0.0, 0.0, 0.0,
   -lo, -hi, -lo
);
mat3 sy = mat3(
    lo, 0.0, -lo,
    hi, 0.0, -hi,
    lo, 0.0, -lo
);

	vec3 front = texture2D(Front, st).rgb;
	mat3 I;
  float o = 0.0;

	for (int i = 0; i < 3; i++) {
		for (int j = 0; j < 3; j++) {
			vec3 color = texture2D(Front, st + vec2(i - 1, j - 1) * texel).rgb;
			I[i][j] = length(color);
		}
	}

	float gx = dot(sx[0], I[0]) + dot(sx[1], I[1]) + dot(sx[2], I[2]);
	float gy = dot(sy[0], I[0]) + dot(sy[1], I[1]) + dot(sy[2], I[2]);
  float angle = atan(gy / gx);

  //float mult = PI * .1; //This widens the edge;
	float g = mult * sqrt(1.0 - (pow(gx, 2.0) + pow(gy, 2.0)));
	//g = sqrt(1.0 - (pow(gx, 2.0) + pow(gy, 2.0)));

  o = smoothstep(0.0, .99, g);
  vec3 norm = normalize(vec3(2.0 * gx, 2.0 * gy, g * bump));


	gl_FragColor = vec4(o);
	gl_FragColor.rgb = norm;
}
