#version 120

#define PI 3.1415926535897932
#define ratio adsk_result_frameratio
#define HALF_PIXEL 0.5

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
uniform float adsk_results_pass2_w, adsk_results_pass2_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D adsk_texture_grid;
uniform sampler2D Front;
uniform vec2 sample_coords;
uniform bool output_color;
uniform bool action_coords;
uniform vec3 action_sample_coords;

vec2 char_size = vec2(100, 100);
vec2 grid_size = vec2(200, 600);

vec2 pos(int num) {
  float n = float(num);

  // Get total amount of tiles x and y
  // x = 200 / 100 = 2
  // y = 600 / 100 = 6
  // 2 x 6 grid
  vec2 total = grid_size / char_size;

  // Get coords of tile identified by num
  // mod(5, 2) = 1
  // 5 / 2  = 2.5
  //bottom left location of char i vec2(1, floor(2.5))
  vec2 char_coords = vec2(mod(n, total.x), floor(n / total.x));

 // multiply by char_size to get actual location in texture
  return char_coords * char_size;
}

 vec4 get_char(vec2 char_pos, vec2 xy_offset, vec2 loc1) {
   vec2 xy = gl_FragCoord.xy - xy_offset;
   xy -= loc1 * res;
   xy /= vec2(.5);

   // Return black if coords are outside of charactor bounds
   if (any(greaterThan(xy, char_size)) || any(lessThan(xy, vec2(0)))) {
     return vec4(0.0);
   }

   // Offset and normalize
   vec2 p = (char_pos + (xy)) / grid_size;

   vec4 char_texture = texture2D(adsk_texture_grid, p);

   return char_texture;
 }

 float make_circle(vec2 coords, vec2 l, float size) {
   coords.x *= adsk_result_frameratio;
   l.x *= adsk_result_frameratio;
   float d1 = distance(coords, l);
   float circle = 1.0 - smoothstep(size, size + .003, d1);
   coords.x /= adsk_result_frameratio;
   l.x /= adsk_result_frameratio;

   return circle;
 }

vec2 convert_for_action(vec3 coords) {
  coords.rg /= res;
  coords.rg = coords.rg + vec2(1.0) * vec2(.5);

  return coords.rg;
}

void main(void) {
  vec2 st = gl_FragCoord.xy / res;
  vec2 scoords = sample_coords;

  if (action_coords) {
    scoords = convert_for_action(action_sample_coords);
  }

  vec3 sampled_color = texture2D(Front, scoords).rgb;
  vec4 outcol = vec4(0.0);

  if (output_color) {
    outcol.rgb = sampled_color;
  } else {
    float inner_circle = make_circle(st, scoords, .135);
    float border = make_circle(st, scoords, .140);
    float outer_circle = make_circle(st, scoords, .165);
    vec3 front = texture2D(Front, st).rgb;

    st -= scoords;
    st /= vec2(6);
    st += scoords;

    vec3 front_big = texture2D(Front, st).rgb;

    outcol.rgb = mix(front, sampled_color, outer_circle);
    outcol.rgb = mix(outcol.rgb, vec3(.7), border);
    outcol.rgb = mix(outcol.rgb, front_big, inner_circle);

    float y_offset = 0;
    float channels[] = float[](sampled_color.r, sampled_color.g, sampled_color.b);
    vec3 rgb[] = vec3[](vec3(.3, .1, .1), vec3(.1, .3, .1), vec3(.1, .1, .3));

    for (int j = 0; j < 3; j++) {
      float channel = channels[j];
      float x_offset = 180;
      float alpha = 0.0;

      for (int i = 0; i < 5; i++) {
        float digit = floor(channel);
        vec2 char_pos = pos(int(digit));

        y_offset = -35.0 * float(j) + 10;

        if (i == 0) {
          alpha += get_char(char_pos, vec2(x_offset, y_offset), scoords).r;
          char_pos = pos(10);
          x_offset += 17;
          alpha += get_char(char_pos, vec2(x_offset, y_offset), scoords).r;
          x_offset -= 10;
        } else {
          x_offset += 25;
          alpha += get_char(char_pos, vec2(x_offset, y_offset), scoords).r;
        }

        channel -= digit;
        channel *= 10.0;
      }

      outcol.rgb = mix(outcol.rgb, rgb[j], alpha);
    }
  }

	gl_FragColor = outcol;
}
