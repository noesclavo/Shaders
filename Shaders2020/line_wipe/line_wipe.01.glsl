#version 120

#define fratio adsk_result_frameratio
#define pratio adsk_result_pixelratio

const float PI = 3.1415926535897932;

uniform float adsk_time;
uniform float adsk_result_frameratio;
uniform float adsk_result_pixelratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = vec2(1.0) / res;

uniform sampler2D Outgoing;
uniform sampler2D Incoming;

uniform float vertical;
uniform float horizontal;
uniform float v_offset;
uniform float h_offset;
uniform float line_width;
uniform vec3 line_color;
uniform float line_softness;
uniform vec3 circle_color;
uniform int matte_output;
uniform float line_opacity;
uniform float rotation;
uniform vec2 center;
uniform float width;
uniform float circle_size;
uniform float circle_softness;
uniform float circle_offset;
uniform float draw;
uniform bool circles;
uniform bool vwipe;

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
    float rot = radians(r);

    mat2 rm = mat2(
        cos(rot), sin(rot),
        -sin(rot), cos(rot)
    );

    coords.x *= adsk_result_frameratio;
    coords *= rm;
    coords.x /= adsk_result_frameratio;

    return coords;
}

float make_circle(vec2 coords) {
    vec2 st_m = coords / (line_width * texel * vec2(adsk_result_frameratio, 1.0));

    float d = 1.0 - distance(vec2(0.5), fract(st_m));
    float circle = smoothstep(1.0 - circle_size, 1.0 - circle_size + .01, d);
    
    return circle;
}

float make_square(vec2 coords) {
    vec2 uv = coords;

    vec2 bottom_left = step(vec2(1.0 - draw - 1.0) * vec2(adsk_result_frameratio, 1.0), uv);
    vec2 top_right = step(vec2(1.0 - draw - 1.0) * vec2(adsk_result_frameratio, 1.0) , -uv);

    float square = bottom_left.x * bottom_left.y * (top_right.x * top_right.y);
    square = clamp(square, 0.0, 1.0);

    return square;
}

vec2 prep_uvs(vec2 coords) {
    vec2 uv = coords * 2.0 - 1.0;
    uv -= vec2(v_offset, h_offset);
    if (vwipe) {
        uv = abs(uv) * vec2(adsk_result_frameratio, 1.0);
        uv = rotate_coords(uv, rotation);
    } else {
        uv = rotate_coords(uv, rotation);
        uv = abs(uv) * vec2(adsk_result_frameratio, 1.0);
    }

    return uv;
}

vec2 get_softness() {
    vec2 softness = vec2(texel) * vec2(adsk_result_frameratio, 1.0) * line_softness;

    return softness;
}

vec3 wipe(vec2 uv, vec2 softness) {
    vec2 vh = vec2(vertical * texel.x, horizontal * texel.y) * vec2(adsk_result_frameratio, 1.0) * 2.0;

    float vmatte = 1.0 - smoothstep(vh.x - softness.x, vh.x, uv.x);
    float hmatte = 1.0 - smoothstep(vh.y - softness.y, vh.y, uv.y);

    float matte = max(vmatte, hmatte);

    vec3 vh_matte = vec3(vh, matte);

    return vh_matte;
}

vec3 make_line(vec2 uv, vec2 vh, vec2 softness) {
    vec2 line_pos = vh - vec2(line_width) * vec2(adsk_result_frameratio, 1.0) * texel;

    float vline = 1.0 - smoothstep(line_pos.x - softness.x, line_pos.x, uv.x);
    float hline = 1.0 - smoothstep(line_pos.y - softness.y, line_pos.y, uv.y);

    float line = max(vline, hline);

    return vec3(line_pos, line);
}

void main(void) {
    vec2 xy = gl_FragCoord.xy;
    vec2 st = xy * texel;

    vec2 uv = prep_uvs(st);
    float draw_on = make_square(uv);

    vec3 outgoing = texture2D(Outgoing, st).rgb;
    vec3 incoming = texture2D(Incoming, st).rgb;

    vec2 softness = get_softness();
    vec3 vh_matte = wipe(uv, softness);

    float wipe_matte = vh_matte.z;
    vec2 vh = vh_matte.xy;

    vec3 line = make_line(uv, vh, softness);
    float line_matte = clamp(wipe_matte - line.z, 0.0, 1.0);

    vec3 outcol = mix(outgoing, incoming, clamp(wipe_matte - line_matte, 0.0, 1.0));
    outcol = mix(outcol, line_color, clamp(line_matte * 10, 0.0, 1.0) * line_opacity * draw_on);

    float circle = 0.0;
    if (circles) {
        circle = make_circle(uv - line.xy);
        outcol = mix(outcol, circle_color, circle * line_matte * draw_on);
    }


    float out_matte = line_matte;
    if (matte_output == 1) {
        out_matte = wipe_matte;
    } else if (matte_output == 2) {
        out_matte = circle;
    }

    gl_FragColor = vec4(outcol, out_matte);
}
