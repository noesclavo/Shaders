//http://www.crytek.com/download/Sousa_Graphics_Gems_CryENGINE3.pdf
//http://psgraphics.blogspot.com/2011/01/improved-code-for-concentric-map.html
//https://www.shadertoy.com/view/MtlGRn

#version 120

#define ratio adsk_result_frameratio
#define pr adsk_result_pixelratio
#define PI 3.141592653589793238462643383279502884197969
#define min_fstops 2.0
#define max_fstops 5.6

float adsk_getLuminance( in vec3 color );
float adsk_highlights( in float pixel, in float halfPoint );

uniform float ratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D adsk_results_pass1;
uniform sampler2D adsk_results_pass2;
uniform sampler2D adsk_results_pass3;
uniform int sides;
uniform float fstops;
uniform int samples;
uniform float width;
uniform float aspect;
uniform float rotate;
uniform bool show_kernel;
uniform bool clamp_output;
//uniform bool show_threshold;
uniform float shutter_angle;

uniform float noise_amount;
uniform float noise_size;
uniform float seed;

float noise_a = noise_amount + 1.0;

uniform int make_depth;
uniform int grad_center;
uniform vec2 grad_1;
uniform vec2 grad_2;



vec2 CosSin(float x) {
	vec2 si = fract(vec2(0.5,1.0) - x*2.0)*2.0 - 1.0;
	vec2 so = sign(0.5-fract(vec2(0.25,0.5) - x));
	return (20.0 / (si*si + 4.0) - 4.0) * so;
}

float rand(vec2 coords, float seed) {
	return fract(CosSin(dot(coords.xy, vec2(12.989 + mod(seed, 10.0), 78.233))) * 43758.5453).r;
}

float get_threshold(vec3 col, float t)
{
	float luma = adsk_getLuminance(col);
	float h = adsk_highlights(luma, t);
	h = step(t, luma);

	return h;
}

vec2 rotate_coords(vec2 coords, float ra) {
	ra = radians(ra);

	mat2 r = mat2( cos(-ra), -sin(-ra),
                   sin(-ra), cos(-ra) );

	if (show_kernel) {
		coords *= r;
	} else {
		coords.x *= ratio;
		coords *= r;
		coords.x /= ratio;
	}

	return coords;
}

vec2 to_concentric(vec2 coords) {
  float phi;
  float r;

	float a = 2.0 * coords.x - 1.0;
	float b = 2.0 * coords.y - 1.0;
	vec2 ret = vec2(0.0);

   if (a * a > b * b) {
		// same thing as .. if (abs(a) > abs(b)) {
		// a > .0000001
		// keeps us from dividing by zero
		if (abs(a) > 1e-8) {
     	r = a;
     	phi = (PI / 4) * (b / a);
			ret = vec2(phi, r);
		} else {
			ret = vec2(0.0, a);
		}
  } else {
		// b > .0000001
		if (abs(b) > 1e-8) {
    	r = b;
    	phi = (PI / 2 ) - (PI / 4 ) * (a / b);
			ret = vec2(phi, r);
		} else {
			ret = vec2(0.0, b);
		}
  }

  float noise_x = rand(ret, 1);
  float noise_y = rand(ret, 2);
	return mix(vec2(noise_x, noise_y), ret, 0.95 + noise_a*0.05);
}

vec2 get_ngon(vec2 c_coords) {
	c_coords = to_concentric(c_coords);

  float theta = c_coords.x;
  float r = c_coords.y;

	// controls roundness of bokeh
  float f = (fstops - min_fstops) / (max_fstops - min_fstops);
  //theta = theta + f * radians(shutter_angle);
  theta = theta + f;

  float cos_pi_n = cos(PI / sides);
  //float cos_angle = cos(theta - (2 * PI / sides) * floor((sides * theta + PI) / (2.0 * PI)));
	float theta_mod_sides = mod(theta, 2.0 * PI / sides);
	float cos_angle = cos(theta_mod_sides - PI / sides);

	// controls roundess of bokeh
  float rgon = r * pow(cos_pi_n / cos_angle, f);

	c_coords = vec2(cos(theta), sin(theta)) * vec2(rgon);

	return c_coords;
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec4 front_cc = texture2D(adsk_results_pass3, st);
	float blur_factor = texture2D(adsk_results_pass2, st).a;

	float w = 1.0;

	vec2 coord = (st - vec2(0.5)) * 4.0 * vec2(ratio, 1.0);

	float v = 0.0;
	float s = max(1.0, float(samples));
  s = min(s, 60.0);
	vec4 color = front_cc;

	for(float y = 0.0; y <= 1.0; y += 1.0 / s){
    for(float x = 0.0; x <= 1.0; x += 1.0 / s){
			vec2 c = vec2(x, y);
     	c = get_ngon(c);

			if (! show_kernel) {
        float mm = .001;
				c *= vec2(width * mm / ratio * aspect, width * mm);
				c = rotate_coords(c, rotate);

				vec2 sample_coords = st + c * vec2(blur_factor);
				vec4 blur = texture2D(adsk_results_pass3, sample_coords);

				color += blur;

				w++;
			} else {
				//c.x *= aspect;
				c = rotate_coords(c, rotate);
				//.01 is the width of the dots representing the kernel
				v = mix(1.0, v, pow(smoothstep(0.0, 0.02, length(coord - c)), 1.0));
			}
		}
    }

	if (! show_kernel) {
		color /= vec4(w);
	} else {
		color.rgb = vec3(v);
	}

	if (clamp_output) {
		color = clamp(color, 0.0, 1.0);
	}

	//if (show_threshold) {
		//color.a = front_cc.a;
	//}

	gl_FragColor = color;
}
