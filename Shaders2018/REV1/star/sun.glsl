vec3 adsk_hsv2rgb( in vec3 src );

uniform float time;
uniform float adsk_time;
varying vec2 v_texCoord2D;
varying vec3 v_texCoord3D;
uniform vec4 v_color;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform float glow;
uniform float falloff;
uniform float color_offset;

uniform vec3 tint;
uniform float gain;
uniform float g;
uniform float color_drift;

vec3 getRGB( float hue, float sat)
{
    vec3 rgb =  adsk_hsv2rgb( vec3( hue, sat, 1.0 ) );

    rgb = clamp(rgb, 0.0, 1.0);

    return rgb;
}

void main(void)
{
  vec2 st = gl_FragCoord.xy / res;

	vec2 fpos = st * vec2(2.) - vec2(1.);
  fpos.x *= adsk_result_frameratio;

  // make a ring
  //float dist1 = 1.0 - distance(fpos / .5, vec2(0.0));
  //float c  = 1.0 - pow(dist1, gain);

  // make a sun with glow
  //float dist1 = 1.0 - distance(fpos / .25, vec2(0.0));
  //float  c = pow(dist1, g);
  //c = exp(dist1);

  float dist1 = distance(fpos / .8, vec2(0.0));
  float  c = 1.0 - pow(dist1, .03001);
  c *= exp(1. + gain);

  //fpos.x /= adsk_result_frameratio;
  //float qx = distance(abs(fpos.x), 1.);
  //float qy = distance(abs(fpos.y), 1.);

  vec3 g_offset = getRGB( tint.x / 360.0 - dist1 * color_drift / 360., tint.y * .01 ) * vec3( tint.z * 0.01);
  c = clamp(c, 0.0, 1.0);
  vec3 col1 = vec3(c) * g_offset;


  vec3 outcol = col1;


  gl_FragColor = vec4(outcol, 0);
}
