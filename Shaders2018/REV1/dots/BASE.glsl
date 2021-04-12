#version 120

#define PI 3.1415926535897932
#define fratio adsk_result_frameratio
#define pratio adsk_result_pixelratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;
uniform vec2 p0, p1, p2 ,p3;
uniform float t;
uniform float delta;


vec2 toBezier(float delta, int i, vec2 P0, vec2 P1, vec2 P2, vec2 P3)
{
    float t = delta * float(i);
    float t2 = t * t;
    float one_minus_t = 1.0 - t;
    float one_minus_t2 = one_minus_t * one_minus_t;
    return (P0 * one_minus_t2 * one_minus_t + P1 * 3.0 * t * one_minus_t2 + P2 * 3.0 * t2 * one_minus_t + P3 * t2 * t);
}
vec2 b3_translation( in vec2 p0, in vec2 p1, in vec2 p2, in vec2 p3, in float t )
{
   float tt = (1.0 - t) * (1.0 - t);

   return tt * (1.0 - t) * p0 +
       3.0 * t * tt * p1 +
                3.0 * t * t * (1.0 - t) * p2 +
                t * t * t * p3;
}

vec2 b3_mix( vec2 p0, vec2 p1,
         vec2 p2,  vec2 p3,
 in float t )
{
   vec2 q0 = mix(p0, p1, t);
   vec2 q1 = mix(p1, p2, t);
   vec2 q2 = mix(p2, p3, t);

   vec2 r0 = mix(q0, q1, t);
   vec2 r1 = mix(q1, q2, t);

   return mix(r0, r1, t);
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec4 outcol = vec4(0.0);

	st *= 10.0;
	vec2 d = b3_mix( p0, p1, p2, p3, t);
	float dist = length(d - (st));
	dist = 1.0 - smoothstep(.01, .011, dist);
	outcol = vec4(dist);


	gl_FragColor = outcol;
}
