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
uniform float scale;

uniform bool turb;
uniform vec3 seed;
uniform float freq_turb;
uniform vec3 pos;
uniform vec3 frequency;
uniform float frequency_all;
uniform bool gang_frequency;

uniform vec3 amplitude;
uniform float amplitude_all;
uniform bool gang_amplitude;


#define NUM_OCTAVES 8

vec2 CosSin(float x) {
    vec2 si = fract(vec2(0.5,1.0) - x*2.0)*2.0 - 1.0;
    vec2 so = sign(0.5-fract(vec2(0.25,0.5) - x));

    return (20.0 / (si*si + 4.0) - 4.0) * so;
}

float hash(vec2 p, float s) {
    float s1 = sin(17.0 * p.x + p.y * 0.1);
    float s2 = sin(p.y * 13.0 + p.x);

    return fract(1e4 * s * s1 * (0.1 + abs(s2)));
}

float noise(vec2 x, float s) {
	vec2 i = floor(x);
	vec2 f = fract(x);

	// Four corners in 2D of a tile
	float a = hash(i, s);
	float b = hash(i + vec2(1.0, 0.0), s);
	float c = hash(i + vec2(0.0, 1.0), s);
	float d = hash(i + vec2(1.0, 1.0), s);

	// Simple 2D lerp using smoothstep envelope between the values.
	// return vec3(mix(mix(a, b, smoothstep(0.0, 1.0, f.x)),
	//			mix(c, d, smoothstep(0.0, 1.0, f.x)),
	//			smoothstep(0.0, 1.0, f.y)));

	// Same code, with the clamps in smoothstep and common subexpressions
	// optimized away.
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 x, float s) {
	float v = 0.0;
	float a = 0.5;
	vec2 shift = vec2(100);
	// Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
	for (int i = 0; i < NUM_OCTAVES; ++i) {
		v += a * noise(x, s);
		x = rot * x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}

void main(void) {
    vec2 st = gl_FragCoord.xy / res;
    vec4 outcol = vec4(0.0);

    float frequency_turb = fbm(st, 123.);
    frequency_turb = abs((frequency_turb - .5) * 2.0);

    float fx = frequency.r;
    float fy = frequency.g;
    float fz = frequency.b;

    if (gang_frequency) {
        fx = fy = fz = frequency_all;
    }
    
    vec2 p = st;
    p -= vec2(.5 * seed.rg);
    p.x *= adsk_result_frameratio;
    p *= mix(-vec2(fx, fy), -vec2(fx, fy) * frequency_turb, freq_turb);

    float f = fbm(p, seed.r);
    outcol.r = f;
    f = fbm(p, seed.g);
    outcol.g = f;

    p = st;
    p -= vec2(.5 * seed.b);
    p.x *= adsk_result_frameratio;
    p *= mix(-vec2(fz), -vec2(fz) * frequency_turb, freq_turb);

    f = fbm(p, seed.b);
    outcol.b = f;

    outcol = (outcol - vec4(.5)) * vec4(2.0);
    vec3 s = sign(outcol.rgb);
    outcol = abs(outcol);

    vec3 amp = amplitude;
    if (gang_amplitude) {
        amp = vec3(amplitude_all);
    }

    if (fx == 0.0) {
        amp.r = 0.0;
    }

    if (fy == 0.0) {
        amp.g = 0.0;
    }

    if (fz == 0.0) {
        amp.b = 0.0;
    }

    outcol.rgb *= s;
    outcol.rgb *= amp;

    gl_FragColor = outcol;
}

