#version 120

#define ratio adsk_result_frameratio
#define FrontPremult adsk_results_pass1

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Strength;
uniform sampler2D FrontPremult;

uniform int repeat;
uniform vec2 center;
uniform float rotation;
uniform vec2 scale;
uniform float uniform_scale;
uniform vec2 translate;

vec2 repeat_coords(vec2 coords) {
	//tile
	if (repeat == 1) {
		if (coords.x > 1.0 || coords.x < 0.0) {
			coords.x = fract(coords.x);
		}
		if (coords.y > 1.0 || coords.y < 0.0) {
			coords.y = fract(coords.y);
		}
	//mirror
	} else if (repeat == 2) {
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
	} else if (repeat == 3) {
        if (coords.x > 1.0 || coords.x < 0.0) {
            discard;
        }
		if (coords.y > 1.0 || coords.y < 0.0) {
            discard;
        }
	}

	return coords;
}

vec2 rotate_coords(vec2 coords, float r)
{
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

vec2 scale_coords(vec2 coords, vec2 scale) {
	coords -= center;
	coords /= scale;
	coords += center;

	return coords;
}

vec2 translate_coords(vec2 coords, vec2 t) {
	coords -= t / res;

	return coords;
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;
	vec2 coords = st;

	float strength = abs(texture2D(Strength, st).r);

	vec4 warped = vec4(0.0);

	vec2 scale_val = (scale / vec2(100)) * (uniform_scale / 100);

	coords = rotate_coords(coords, rotation * strength);
	coords = scale_coords(coords, mix(vec2(1.0), scale_val, strength));
	coords = translate_coords(coords, translate * vec2(strength));

	//crop
	if (repeat == 3) {
		if (all(greaterThan(coords, vec2(0.0))) && all(lessThan(coords, vec2(1.0))) ) {
			warped = texture2D(FrontPremult, coords);
		}
	} else {
		coords = repeat_coords(coords);
		warped = texture2D(FrontPremult, coords);
	}

	gl_FragColor = warped;
}
