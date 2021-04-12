#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform int cells;

vec2 CosSin(float x) {
	vec2 si = fract(vec2(0.5,1.0) - x*2.0)*2.0 - 1.0;
	vec2 so = sign(0.5-fract(vec2(0.25,0.5) - x));
	return (20.0 / (si*si + 4.0) - 4.0) * so;
}

float rand(vec2 coords, float seed) {
	return fract(CosSin(dot(coords.xy, vec2(12.989 + seed, 78.233))) * 43758.5453).r;
}

vec2 voronoi(vec2 x) {
  vec2 x_floor = floor( x );
  vec2 x_fract = fract( x );

	vec3 m = vec3( 8.0 );

  for(int j = -1; j <= 1; j++) {
    for(int i = -1; i <= 1; i++) {
      vec2  g = vec2(i, j);
			vec2 rand_coord = x_floor + g;

      float  x_rand = rand(rand_coord, .17);
      float  y_rand = rand(rand_coord, .13);

			vec2 o = vec2(x_rand, y_rand);

      vec2  r = g - x_fract + o;
			float d = dot( r, r );

      if(d < m.x ) {
        m = vec3( d, o );
			}
    }
	}

  return vec2(sqrt(m.x), m.y + m.z);
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec2 c = voronoi(vec2(cells) * st);

	vec3 col = 0.5 + 0.5 * cos( c.y * 6.2831 + vec3(0.0,1.0,2.0) );
	col = vec3(fract(c.y));

	vec3 front = texture2D(Front, vec2(fract(c.y))).rgb;

	gl_FragColor.rgb = front;
}
