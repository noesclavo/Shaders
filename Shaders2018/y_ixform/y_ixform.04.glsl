#version 120
#define PI 3.141592653589793238462643383279502884197969


uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform sampler2D adsk_results_pass1;
uniform sampler2D adsk_results_pass3;
uniform sampler2D Vectors;

uniform float pos_x, pos_y;
uniform float scale, scale_x, scale_y;
uniform float rot;
uniform float skew_x, skew_y;

uniform float trans;

uniform bool repeat_texture;
uniform bool warped_only;
uniform bool strength_are_vectors;
uniform bool show_vectors;
//uniform bool use_vectors;

//const vec2 center = vec2(.5);
//:scale:1.0
//:scale_x:1.0
//:scale_y:1.0
//:center:vec2(.5)

uniform vec2 center;

bool isInTex( const vec2 coords )
{
	    return coords.x >= 0.0 && coords.x <= 1.0 &&
		            coords.y >= 0.0 && coords.y <= 1.0;
}


vec2 pre(vec2 coords)
{
	coords -= center;
	coords.x *= adsk_result_frameratio;

	return coords;
}

vec2 post(vec2 coords)
{
	coords.x /= adsk_result_frameratio;
	coords += center;

	return coords;
}

vec2 rotate_coords(vec2 coords, float r)
{
	float rot = radians(r);

	mat2 rm = mat2(
		cos(rot), sin(rot),
		-sin(rot), cos(rot)
	);

	coords = pre(coords);
	coords *= rm;
	coords = post(coords);

	return coords;
}

vec2 scale_coords(vec2 coords, vec2 scale_val)
{
	scale_val /= 100.0;
	coords = pre(coords);
	coords /= scale_val;// + vec2(1.0);
	coords = post(coords);

	return coords;
}

vec2 skew_coords(vec2 coords, vec2 skew_val)
{
	mat2 sm = mat2(
		1.0, skew_val.x,
		skew_val.y, 1.0
	);

	coords *= sm;

	return coords;
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec3 back = texture2D(Front, st).rgb;

	vec3 strength = vec3(0.0);
	vec3 strength_texture = texture2D(adsk_results_pass3, st).rgb;

	if (strength_are_vectors) {
		strength = strength_texture;
	} else {
		strength = vec3(strength_texture.r);
	}

	vec2 fcoords = st;

	vec2 s = vec2(strength);

	vec2 pos = vec2(pos_x, pos_y);

	fcoords = scale_coords(fcoords, vec2(scale) * vec2(scale_x, scale_y));// * strength.rg);
	//fcoords = skew_coords(fcoords, vec2(skew_x, skew_y) * strength.rg);
	//fcoords = fcoords - pos / res * strength.rg;
	//fcoords = rotate_coords(fcoords, rot * (strength.r * strength.g));

	/*
	fcoords = scale_coords(fcoords, vec2(scale) * vec2(scale_x, scale_y) * s);
	fcoords = skew_coords(fcoords, vec2(skew_x, skew_y) * s);
	fcoords = fcoords - pos / res * s;
	fcoords = rotate_coords(fcoords, rot * strength);
	*/

	vec4 col = texture2D(adsk_results_pass1, fcoords);
	vec3 warped = col.rgb;
	float matte = col.a;

	if (! repeat_texture && ! isInTex(fcoords)) {
		warped = vec3(0.0);
		matte = 0.0;
	}

	float alpha = mix(matte, 0.0, trans);

	if (matte > 0.0 && ! warped_only) {
		warped /= vec3(matte);
	}

	vec3 comp = mix(back, warped, alpha);

	if (warped_only) {
		comp = warped;
	}

	if (show_vectors && strength_are_vectors) {
    comp = strength_texture;
  }

	gl_FragColor = vec4(comp, alpha);
}
