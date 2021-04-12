#version 120
#define PI 3.1415926535897932

#define ratio adsk_result_frameratio

float adsk_result_pixelratio;

float adsk_getLuminance( in vec3 color );

uniform sampler2D adsk_results_pass1;
uniform sampler2D Front;
uniform sampler2D Matte;
uniform sampler2D Strength;

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform int rotation;
uniform vec2 center;
uniform int repeat;
uniform int samples;

vec2 rotate_coords(vec2 coords, float r) {
	float rot = radians(r);

	mat2 rm = mat2(
		cos(rot), sin(rot),
		-sin(rot), cos(rot)
	);

	coords -= center;
	coords.x *= ratio;
	coords *= rm;
	coords.x /= ratio;
	coords += center;

	return coords;
}

vec4 rotblur(vec2 st) {
    vec4 warped = vec4(0.0);
    float strength = texture2D(Strength, st).r;

    int r = 0;
    float rot = abs(float(rotation));
    float q = 1.0 / samples;

    for (float i = 0 ; i <= rot * strength ; i+=q) {
        vec2 uv = rotate_coords(st, i * sign(float(rotation)));
        warped += texture2D(adsk_results_pass1, uv);
        r++;
    }

    warped /= vec4(r);

    return warped;
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;
    vec3 front = texture2D(Front, st).rgb;
    float matte = texture2D(Matte, st).r;

    vec4 warped = rotblur(st);
    if (warped.a > 0.0) {
        warped.rgb /= warped.a;
    }

	gl_FragColor = warped;
}
