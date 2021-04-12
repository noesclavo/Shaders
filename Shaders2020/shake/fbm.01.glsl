#define PI 3.1415926535897932
#define fratio adsk_result_frameratio
#define pratio adsk_result_pixelratio

uniform int adsk_result_execution;
uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Front;
uniform sampler2D adsk_results_pass1;

uniform float x_freq;
uniform float y_freq;
uniform float zoom_freq;
uniform float rotation_freq;

uniform float x_amp;
uniform float y_amp;
uniform float zoom_amp;
uniform float rotation_amp;

uniform bool show_shake;
uniform int outcol;

float time = adsk_time;

const mat2 m2 = mat2(0.8,-0.6,0.6,0.8);

vec2 repeat_coords(vec2 coords, int repeat) {
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
        if (mod(floor(coords.x), 2.0) != 0.0) {
            coords.x = 1.0 - fract(coords.x);
        } else {
            coords.x = fract(coords.x);
        }
        if (mod(floor(coords.y), 2.0) != 0.0) {
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

vec2 rotate_coords(vec2 coords, float r) {
    float rot = radians(r);
    vec2 center = vec2(.5);

    mat2 rm = mat2(
        cos(rot), sin(rot),
        -sin(rot), cos(rot)
    );

    coords -= center;
    coords.x *= adsk_result_frameratio;
    coords *= rm;
    coords.x /= adsk_result_frameratio;
    coords += center;

    coords = repeat_coords(coords, 2);

    return coords;
}

float random (vec2 st) {
    return fract(sin(dot(st, vec2(12.9898, 78.233)))* 43758.5453123);
}

float noise (vec2 st) {
    vec2 i = st;
    vec2 f = st;

    float t = time;

    i = floor(st);
    f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

float fbm( vec2 p ) {
    p *= vec2(.01);
    float f = 0.0;
    f += 0.5000 * noise( p ); p = m2 * p * 2.02;
    f += 0.2500 * noise( p ); p = m2 * p * 2.03;
    f += 0.1250 * noise( p ); p = m2 * p * 2.01;
    f += 0.0625 * noise( p );

    return f/0.9375;
}

void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy / res;
    vec2 uv = st * 2.0 - vec2(1.0); 

    uv.x *= fratio;

    vec2 x_vec = vec2(.1, .9);
    vec2 y_vec = rotate_coords(vec2(.7, .3), 70.0);
    vec2 z_vec = rotate_coords(vec2(.2, .5), 200.0);
    vec2 r_vec = rotate_coords(vec2(.9, .7), 130.0);

    float x = fbm((uv + x_vec) * x_freq * res.x);
    float y = fbm((uv + y_vec) * y_freq * res.y);
    float z = fbm((uv + z_vec) * zoom_freq * res.x);
    float r = fbm((uv + r_vec) * rotation_freq * res.x);

    vec4 shake = vec4(x, y, z, r);
   
  
    gl_FragColor = shake;
}
