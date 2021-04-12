#version 120

vec3  adsk_hsv2rgb( vec3 hsv );

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform sampler2D Matte;
uniform vec3 gamma;
uniform vec3 gain;
uniform vec2 position;
uniform vec2 scale;
uniform vec2 center;
uniform vec2 shear;
uniform float imix;
uniform float angle;

vec3 getRGB( float hue, float sat) {
    vec3 rgb =  adsk_hsv2rgb( vec3( hue, sat, 1.0 ) );

    rgb = clamp(rgb, 0.0, 1.0);

    return rgb;
}

void main(void) {
	vec2 st = gl_FragCoord.xy / res;

	vec3 orig = texture2D(Front, st).rgb;
	float matte = texture2D(Matte, st).r;

  mat2 shear_mat = mat2(
    1, shear.x / 100,
    shear.y / 100, 1
  );

  float rad = radians(angle);
  mat2 rotation_mat = mat2(
    cos(rad), -sin(rad),
    sin(rad), cos(rad)
  );


	st -= center;
  st.x *= adsk_result_frameratio;
  st *= rotation_mat;
  st.x /= adsk_result_frameratio;
	st /= scale / vec2(100);
  st *= shear_mat;
	st += center;
	st -= position * texel;

	vec3 front = texture2D(Front, st).rgb;

	vec3 gamma_o = getRGB(gamma.x / 360.0, gamma.y * .01) * gamma.z;

  //front = vec3(1.0) - front;
  front = pow(abs(front), vec3(1.0) / gamma_o);
  //front = vec3(1.0) - front;

	vec3 gain_o = getRGB(gain.x / 360.0, gain.y * .01) * gain.z * 0.01;
	front *= gain_o;




  float alpha = clamp(matte * imix, 0.0, 1.0);
	front = mix(orig, front, alpha);

	gl_FragColor = vec4(front, matte);
}
