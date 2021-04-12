#version 120

#define PI 3.141592653589793238462643383279502884197969

uniform float adsk_result_w, adsk_result_h;
uniform float adsk_Front_w, adsk_Front_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;

uniform float horizontal_fov;

uniform float pan;
uniform float tilt;
uniform float roll;
uniform float camz;

vec2 rotate_coords(vec2 coords, float r)
{
	float rot = radians(r);

	mat2 rm = mat2(
		cos(rot), sin(rot),
		-sin(rot), cos(rot)
	);

	coords *= rm;

	return coords;
}

vec3 roll_tilt_pan(vec3 p, vec3 angle) {
	p.xy = rotate_coords(p.xy, degrees(angle.z));
	p.yz = rotate_coords(p.yz, degrees(angle.y));
	p.xz = rotate_coords(p.xz, degrees(angle.x));

  return normalize(p);
}

void main(void) {
  vec2 st = gl_FragCoord.xy * vec2(2.0) / res.xy - vec2(1.0);

	float FOV = radians(horizontal_fov);
	FOV = tan(.5 * FOV);

	//Vertical FOV for 2 to 1 image
	float vFOV = FOV * .5;

	vec2 field_of_view = vec2(FOV, vFOV);

	//Initial camera postion
	vec3 camera = vec3(st * field_of_view, -1.0);
	camera = normalize(camera);

	float camera_pan = radians(pan) + PI * .5; // Pan by 90 degrees so we start facing center
	float camera_tilt = radians(tilt);

	vec3 rotation_angles = vec3(
			camera_pan,
			camera_tilt,
			roll
	);

	//Negate angles so the camera moves pans, tilts, and rotates in the correct direction
	vec3 camera_o = roll_tilt_pan(camera, -rotation_angles);

	st = vec2(
		atan(camera_o.z, camera_o.x) + PI,
		acos(-camera_o.y)
	);

	st /= vec2(2.0 * PI, PI);

	vec4 front = texture2D(Front, st);

	gl_FragColor = front;
}
