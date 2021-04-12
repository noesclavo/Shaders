#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform sampler2D UV;
uniform sampler2D Matte;
uniform sampler2D Norm;
uniform sampler2D POS;
uniform sampler2D Reflections;
uniform float eta;
uniform float z;
uniform vec2 n;
uniform vec3 light;
uniform float scale;
uniform int op;
uniform bool reflections;
uniform float reflection_mix;
uniform float chroma;

vec2 repeat_coords(vec2 coords, int repeat) {

  if (repeat == 1) {
    coords = fract(coords);
  } else if (repeat == 2) {
	  vec2 xx = vec2(1.0) - step(vec2(0.0), sin(coords * PI));
	  coords = abs(xx - fract(coords));
  } else if (repeat == 3) {
		if (any(notEqual(clamp(coords, 0.0, 1.0), coords))) {
			discard;
		}
	}

	return coords;
}

void main(void) {
	vec2 xy = gl_FragCoord.xy;
	vec2 st = gl_FragCoord.xy / res;

	vec4 front = texture2D(Front, st);
	float matte = texture2D(Matte, st).r;

	vec3 pos = texture2D(POS, st).rgb;
	pos /= vec3(res, pos.z);
	pos.z = 1;
	pos = (pos + vec3(1.0)) * vec3(.5);

	vec2 uvpass = texture2D(UV, st).rg;
	vec3 norm = texture2D(Norm, st).rgb;
	vec3 ray = pos - vec3(.5, .5, 0);
	ray = pos - vec3(.5, .5, -.5);

	//vec3 inc = ray - 2.0 * dot(normalize(ray), normalize(norm)) * norm;
	vec3 inc = 2.0 * dot(normalize(ray), normalize(norm)) * norm - ray;

	vec3 refraction_vector = refract((inc), (norm), eta);
	vec4 refraction = texture2D(Front, st + refraction_vector.rg);

	refraction.g = texture2D(Front, st + vec2(4) * texel + refraction_vector.rg).g;
	refraction.b = texture2D(Front, st + vec2(8) * texel + refraction_vector.rg).b;

	vec4 reflection = vec4(0.0);
	if (reflections) {
		vec3 reflection_vector = reflect((inc), (norm));
		reflection = texture2D(Reflections, st + reflection_vector.rg);
	}

	vec4 lighting_refl = sqrt(refraction * refraction + reflection * reflection);
	vec4 lighting_refr = sqrt(refraction * refraction);
    vec4 lighting = mix(lighting_refr, lighting_refl, reflection_mix);

	front = mix(front, lighting, matte);


	gl_FragColor = front;
}
