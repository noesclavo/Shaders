#version 120

#define ITERATIONS 4
#define HASHSCALE1 .1031
#define HASHSCALE3 vec3(.1031, .1030, .0973)
#define HASHSCALE4 vec4(1031, .1030, .0973, .1099)

uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;

float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * HASHSCALE1);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

void main(void) {
	vec2 position = gl_FragCoord.xy;

	float a = 0.0, b = a;
    for (int t = 0; t < ITERATIONS; t++) {
      float v = float(t+1)*.152;
      vec2 pos = (position * v + adsk_time * 1500. + 50.0);
    	a += hash12(pos);
    }

		a /= 4.0;

	gl_FragColor = vec4(a);
}
