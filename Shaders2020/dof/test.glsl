#version 120

#define PI 3.1415926535897932
#define fratio adsk_result_frameratio
#define pratio adsk_result_pixelratio

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;
vec2 center =  vec2(.5);

uniform sampler2D Front;

uniform int sides;
uniform float width;
uniform float fstops;
uniform float xxx;
uniform int repeat;
uniform float rotate;
uniform float scale;

#define min_fstops 2.0
#define max_fstops 5.6

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


vec2 rotate_coords(vec2 coords, float r) {
    float rot = r;
    vec2 st = coords;

    mat2 rm = mat2(
        cos(rot), sin(rot),
        -sin(rot), cos(rot)
    );

    //coords.x *= adsk_result_frameratio;
    coords *= rm;
    //coords.x /= adsk_result_frameratio;

    return coords;
}

vec2 to_concentric2(vec2 coords) {
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

    return ret;
}


vec2 to_concentric(vec2 coords) {
    float phi,r;
    float a = 2 * coords.x - 1;
    float b = 2 * coords.y - 1;

    if (a * a > b * b) { // use squares instead of absolute values
        r = a;
        phi = (PI/4)*(b/a);
    } else {
        r = b;
        phi = (PI/2) - (PI/4)*(a/b);
    }

    return vec2( r*cos(phi), r*sin(phi) );
}

vec2 get_ngon(vec2 c_coords) {
    vec2 st = c_coords;
    c_coords = to_concentric2(c_coords);

    float theta = c_coords.x;
    float r = c_coords.y;

    // controls roundness of bokeh
    float f = (fstops - min_fstops) / (max_fstops - min_fstops);
    theta = theta + f;

    float cos_pi_n = cos(PI / sides);
    float cos_theta_two_pi_n = cos(theta - (2.0 * PI / sides) * floor((sides * theta + PI) / 2.0 * PI));

    float rgon = r * pow(cos_pi_n / cos_theta_two_pi_n, f);

    c_coords = vec2(cos(theta), sin(theta)) * vec2(rgon);

    return c_coords;
}



void main(void) {
    vec2 st = gl_FragCoord.xy / res;
    vec2 uv = st;
    vec2 c_coords = to_concentric(st);

    float a = atan(st.x, st.y) + PI;
    float r = 2 * PI / float(sides);
    float d = cos(floor(.5 + a / r) * r - a) * length(st);

    float col = 0.0;
    st = repeat_coords(st);
    //c_coords = rotate_coords(c_coords, rotate);
    
    c_coords = repeat_coords(c_coords);

    gl_FragColor = vec4(mix(c_coords, st, xxx), 0.0, 0.0);
}
